---
title: CloudWatch로 slack으로 경고날리기
tags: 구현 인프라
article_header:
type: cover
---

# 왜? 경고 메시지를 slack으로 받을까?

---

이번 구현기록을 남기기전에 **"왜"** 경고 메시지를 따로 전송하게 되었는지 말하고자 한다.

최근에 팀 도넛 프로젝트를 진행하면서 같은 ec2 인스턴스 내부에 **개발**, **운영**, **디비**를 도커 컨테이너화를 이용하여
서버를 운영중이였는데 cpu 사용이 100%를 찍는 일이 발생하였다.

처음에는 개발 운영서버가 모두 죽었지만 바로 알지 못했고
그마저 떠있던 디비도 cpu 사용률 100%로 디비 컨테이너를 **stop**하는일도 어려운 상태가 발생했다.

어찌저찌 문제를 해결하고 **개발**, **운영**, **디비**를 분리하는 작업을 진행하였지만, 이번 경험을 통해서 모니터링 시스템과,
즉각적인 문제에 대응가능한 경고 알람이 필요하다고 느꼇다.

즉각적인 피드백을 받기좋고 가장 먼저 경고를 받을 수 있는 곳은 메신저인 **slack**이라고 생각하여 **slack**으로 경고 메시지를 받기로 했다.

<br><br>

## 어떻게? slack으로 경고를 받을까?

---

**왜?** 경고 메시지를 받아야 하는지 정의 하였기 떄문에 이제는 구현의 단계로 **어떻게?** 를 생각해보고자 한다.

나는, **aws**의 기능인 **SNS(Simple Notification Service)**, **Lambda**, **CloudWatch**를 이용하려 한다.

먼저 **SNS**부터 진행하겠다.

<br>
<br>

## SNS?

**SNS**는 PUB/SUB형태의 aws내부 혹은 외부 서비스로 메시지를 보내는 서비스입니다.

사진과 같이 작성하고 생성을 하면 됩니다.

<br>

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/sns.png)

<br>
<br>

## CLOUD WATCH 지표생성

---

다음으로는 문제가 발생한 경우 **CloudWatch**가 문제를 트리거 할 수 있도록, 기준을 잡아줘야 합니다.

현재 **CPU** 사용량에 대한 트리깅을 할거기 때문에, 아래와 같은 설정을 인스턴스 이름을 확인 후 진행합니다.

<br>

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/cloudwatch.png)

<br>

다음으로 넘어가게 되면 아래와 같이 경고를 트리거 할 조건을 설정할 수 있습니다. 대표적으로 기간이나 임계치를 설정 할 수 있습니다.

저는 5분동안 CPU사용률이 80%를 초과한 경우 트리거 하도록 설정했습니다.

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/condition2.png)


<br>

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/condition.png)


<br>
<br>

다음으로 넘어가게 되면 아래처럼 알림 전송에 대한 sns연결 부분이 나오는데 좀 전에 생성한 sns을 연결하면 됩니다.

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/connection.png)


<br>
<br>

## slack Web Hook URL 생성하기

---

여기까지 진행했으면 이제 slack으로 넘어가서 WebHook Url을 생성해야 합니다.

슬랙 채널탭을 클릭하고 통합에서 앱추가를 선택하게 되면 아래와 같은 앱이 있습니다. 그것을 추가하고 URL을 받으면 됩니다.

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/webhook.png)

<br>
<br>

## Lambda 함수 생성

---

먼저 aws로 다시 이동해서 Lambda 함수를 생성합니다.

<br>

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/lambda.png)

위 사진과 같이 람다를 생성합니다.

그 후 index.js파일안에 cloudwatch가 트리거 된 후 처리할 일들을 선언합니다.

저는 아래 블로그에서 index.js 파일들을 가져왔습니다.

![참고한 레퍼런스](https://diddl.tistory.com/184#toc-SNS(Simple%20Notification%20Service)%20%EC%A3%BC%EC%A0%9C%20%EC%83%9D%EC%84%B1)

<br>
<br>
<br>

마지막으로 slack webhook 의 URL을 람다의 환경변수에 등록하면 됩니다.

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/state.png)

<br>
<br>

## 최종 구조

---

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/final.png)

여기까지 진행했다면 위 사진처럼 나오게 됩니다.

<br>

## 테스트

여기까지 진행하면 아래처럼 슬랙으로 경고가 날라오게 됩니다.

<br>
<br>

![](https://raw.githubusercontent.com/jickDo/picture/master/Infra/slack알람/test.png)

<br>
<br>

생각보다 간단하게 진행되어 기록을 따로 하지않으면서 진행하여, 정리가 잘 되어있지 못하지만 도움이 되셨다면 좋겠습니다!
