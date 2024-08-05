---
title: RequestBody 그리고 RequestParam
tags: 스프링
article_header:
type: cover
---
# RequestBody 그리고 RequestParam

---

오늘 공부할 내용은 스프링의 어노테이션인 **@RequestParam** 그리고 **RequestBody**이다.

Api개발을 하다보면 당연스럽게 만나는 두가지 어노테이션이지만 사용을 하는 과정에서 한가지 의문점이 생겨서 정리를 해보고자 한다.

위 두가지 어노테이션은 컨트롤러 단에서 데이터를 전송하는 방식을 나타내는 어노테이션이다.

<br><br>

## RequestParam이란?

---

스프링은 HTTP 요청에 대한 파라미터를 @RequestParam으로 받을수 있다. 이름을 기준으로 값을 대조하기 때문에 @RequestParam 내부에 이름에 맞춰 값을 넣어줘야 한다.



````java
@PostMapping("")
    KakaoTokenResponse getKakaoAuthorizationCode(
            @RequestParam("grant_type") String grantType,
   ......
    );
   ````

위처럼 매칭할 이름을 작성하여 파라미터로 받게 된다.

````java
@PostMapping("")
    KakaoTokenResponse getKakaoAuthorizationCode(
        @RequestParam("grant_type") String grantType,
        @RequestParam("client_id") String clientId,
        @RequestParam("redirect_uri") String redirectUri,
        @RequestParam("code") String code
        );
````

위처럼 여러가지 값을 매핑할 수도 있다.

이름에서도 알수있듯이 @RequestParam을 사용하게 되면 값이 파라미터로 추가된다.
주소값 뒤에 **주소?"키"="값"** 형식으로 붙게 된다.

<br><br>

## RequestBody이란?

---

이전 RequestParam이 파라미터를 통한 값전달을 했다면, RequestBody에는 본문에 내용을 담아서 보내게 된다.

````java
@PostMapping("")
    public Long login(@RequestBody LoginResponseDto loginResponseDto)
````

위 코드처럼 RequestBody는 파라미터안의 내용을 Json타입으로 본문에 담아 보낼수 있다.

<br><br>

## 결론

---

1. 스프링 인자전달방식은 @RequestParam 그리고 @RequestBody가 있다.
2. param의 경우는 인자의 구분자를 필요로 하며 쿼리 파라미터로 전달된다.
3. body의 경우는 본문에 내용을 담아 전달하게 된다.


