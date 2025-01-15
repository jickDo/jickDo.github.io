---
title: URL, URI, URN은 무슨차이일까?
tags: 네트워크
article_header:
type: cover
---

# URL / URI / URN 차이점

---

대부분 사용하는 자원 명시자는 **URL**에 익술할 것입니다.

하지만 이번에는 들어보기는 했던 **URI**와, **URN**에 대해서 설명해보겠습니다.

<br>
<br>

<img src="https://raw.githubusercontent.com/jickDo/picture/master/Network/study/3주차/uri.png" width="800" height="400" alt="">

<br>
<br>

그림에서 볼 수 있듯이 **URI**가 가장 큰 범위를 나타내며 그안에 **URN**과, **URL**이 나오게 됩니다.

**URI**의 풀네임은 **Uniform Resource Identifier**이며,

**URN**의 풀네임은 **Uniform Resource Name**이며,

**URL**의 풀네임은 **Uniform Resource Location**입니다.

즉 **URL**은 자원의 위치를 나타내며, **URN**은 자원의 이름, **URI**은 자원의 식별자 까지 나타내게 됩니다.

<br>
<br>

## URI vs URL

---

이번 시간에는 많이 사용하는 두가지 자원 명시자인 **URL**그리고 **URI**를 중심적으로 설명하겠습니다.

<br>

<img src="https://raw.githubusercontent.com/jickDo/picture/master/Network/study/3주차/URL.png" width="800" height="150" alt="">

<br>

웹사이트 검색창에 위 그림과 같은 검색을 하게 됩니다.

각각,

프로토콜, 호스트, 포트, 패스, 파라미터, 앤초 라고 불리는 명칭이 있습니다.

**https://www.example.com:8080/login?name=me&password=123!@#anchor**

이런 전체 주소가 있을때

**https://www.example.com:8080/login** 까지가 **URL**입니다.

왜냐하면 **URL**은 자원의 **Location** 즉 **위치**까지만 명시하면 되기 때문입니다. path 가 **login**인 경우에 특정한 쿼리에 의해서 값이 바뀌는것은

맞지만 결국 그 자원이 속한 위치는 **login**까지입니다. 이후 **?name=me&password=123!@#anchor** 을 포함하는 영역은 **자원의 지시자**라는 명칭을 포함하는

**URI**라고 부르게 됩니다.

결론적으로,

**https://www.example.com:8080/login?name=me&password=123!@#anchor** 에 접속시

- URL (**https://www.example.com:8080/login**)
- URI (**https://www.example.com:8080/login?name=me&password=123!@#anchor**)

입니다.

<br>
<br>

## URN은 뭐야?

---

**URN** 즉 통합 자원 이름은 **urn:schema**를 사용하기 위한 역사적인 이름입니다.

**URN**은 리소스에 이름을 부여하는 역할을 합니다.

하지만 리소스가 이름에 매핑되어 있어야 하기 때문에 이름으로 부여하면 거의 찾기가 힘들기 때문에 실제적으로 사용하기는 힘들다고 합니다.

[참고한 레퍼런스](https://inpa.tistory.com/entry/WEB-%F0%9F%8C%90-URL-URI-%EC%B0%A8%EC%9D%B4)
