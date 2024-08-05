---
title: Apple Oauth 적용기
tags: 구현
article_header:
type: cover
---

## 시작에 앞서

---

전 게시글에서 애플 소셜로그인에서 claim을 추출하는 과정 이후 앱내의 JWT토큰을 이용해서 추가적인 로그인 로직을 진행한다고 했다. 

추가적인 서칭과정중에 기존 로직의 한가지 문제를 발견했다.

---

리젝사유:

[https://medium.com/@tellingme/server-%EC%95%A0%ED%94%8C-%EC%8B%AC%EC%82%AC-%EB%A6%AC%EC%A0%9D%EC%9D%84-%ED%94%BC%ED%95%B4%EB%B3%B4%EC%9E%90-%EC%95%A0%ED%94%8C-%EC%86%8C%EC%85%9C%EB%A1%9C%EA%B7%B8%EC%9D%B8-%ED%83%88%ED%87%B4-%EA%B5%AC%ED%98%84-spring-java-83ed8c6f4e86](https://medium.com/@tellingme/server-%EC%95%A0%ED%94%8C-%EC%8B%AC%EC%82%AC-%EB%A6%AC%EC%A0%9D%EC%9D%84-%ED%94%BC%ED%95%B4%EB%B3%B4%EC%9E%90-%EC%95%A0%ED%94%8C-%EC%86%8C%EC%85%9C%EB%A1%9C%EA%B7%B8%EC%9D%B8-%ED%83%88%ED%87%B4-%EA%B5%AC%ED%98%84-spring-java-83ed8c6f4e86)

[\[Server\] 애플 심사 리젝을 피해보자! — 애플 소셜로그인 탈퇴 구현 (Spring, JAVA)

안녕하세요! 오랜만에 돌아온 서버팀의 키태입니다. 이제 저희 텔링어스 팀은 슬슬 앱스토어 제출을 위해 기존의 기능에서 리젝당할만한 사유가 있는지 점검 중이었습니다. 그 과정에서 나온

medium.com](https://medium.com/@tellingme/server-%EC%95%A0%ED%94%8C-%EC%8B%AC%EC%82%AC-%EB%A6%AC%EC%A0%9D%EC%9D%84-%ED%94%BC%ED%95%B4%EB%B3%B4%EC%9E%90-%EC%95%A0%ED%94%8C-%EC%86%8C%EC%85%9C%EB%A1%9C%EA%B7%B8%EC%9D%B8-%ED%83%88%ED%87%B4-%EA%B5%AC%ED%98%84-spring-java-83ed8c6f4e86)

위 블로그에서 얻은 정보를 바탕으로 회원 탈퇴 로직에서 유저 답변이나 유저 정보를 삭제하는것에 더해 애플 Api서버에서 넘겨주는 토큰을 비활성화 하는 로직도 있어야 한다.

## 플로우

---

탈퇴로직은 로그인로직보다 좀더 생각해야 하는 부분들이 많았는데 우선 로그인시 받는 **A****uthorization Code**의 유효시간이 5분이라는 점과, 그러한 문제때문에 토큰을 다시 받을때 **Refresh Token**을 이용해서 토큰을 매번 다시 받아야 하는 점 등이 있다. 더군다나 기존 **JWT**토큰을 사용하면서 자연스럽게 토큰을 해제하는 로직까지 추가하려고 하니 토큰을 생성하고 해제하는 로직을 어디다가 추가해도 이상한 느낌을 받았기 때문이다.

플로우를 고민하여 나온 두가지 방법이 있다.

---

### 1\. 로그인시 토큰을 생성하고 리프레시 토큰을 디비에 저장하는 경우

첫번째 방법은 회원가입시 토큰을 생성하고 **Refresh Token**을 디비에 저장하여 탈퇴시 **Refresh Token**으로 탈퇴를 하는 로직이다. **revoke token api**는 **Access Token** 과 **Refresh Token**둘다 받는 다는점을 이용해서 기한이 영구적이 **Refresh Token**을 이용하는 방법이다. 

이쪽 로직이 아래로직보다 자연스러운 흐름이기 때문에 처음에는 이 방법을 사용하려고 했다. 하지만 두가지 문제가 있다.

#### 1.  기존 디비에서 Refresh Token 컬럼을 추가해야 하는 문제

이미 사용중인 디비에서 Refresh Token 을 추가해야 한다는 문제가 있다. 하지만 아직 배포를 하고 운용중인 상황이 아니기 때문에 이 부분은 크게 문제가 되는 부분은 아니였다.

문제는 두번째 이유에서 발생한다.

#### 2\. Refresh Token의 유효성을 보장할 수 없는 문제

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/5RefreshTokenValidation.png)

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/6RefreshTokenValidation.png)

위 사진은 애플 개발자 포럼에서 찾은 내용이며, 첫번째가 질문이고, 두번째가 답변에 해당하는 내용이다.

자세히 봐야 할부분은 질문부분인데 애플 **Refresh Token**은 특정 이벤트 (ex.비밀번호 변경)와 같은 상황에서 **Refresh Token**이 변경된다는 점이다. 즉 **Refresh Token**을 저장한다고 해서 항상 유효한 **Refresh Token**임을 더이상 보장할수 없는 상황이다.

위와같은 상황때문에 **Refresh Token**토큰의 유효성을 보장할수 있는 방법을 찾다가 두번째 방법을 생각하게 되었다.

---

### 2\. 탈퇴시 토큰을 생성하고 바로 토큰을 revoke하는 경우

**Refresh Token**이 특정이벤트에 대해서 변경가능성이 있는거라면 특정이벤트가 발생하지 못하는 경우를 만들면 될것이고, 탈퇴시 토큰을 받고 그 토큰을 바로 **revoke**시켜버리면 될것같다는 생각을 하였다.

이렇게 되면 기존로직처럼 **DB**에 사용자의 **Refresh Token**을 저장하지 않아도 된다는 장점이 있고, 또한 **Refresh Token**이 특정 이벤트에 변경될수 있다는 점또한 대응할수 있다는 장점이 있다.

하지만 이방법도 문제점이 하나있었다.

#### 1\. 탈퇴시 사용자가 로그인을 한번 진행해야 한다는 문제

이 방법은 로그인이 되어있어도 탈퇴시 사용자가 애플 로그인을 한번더 진행해야 한다는 문제점이 있다. 왜냐하면 토큰을 발급 받는 과정에서  **A****uthorization Code**을 필요로 하기 때문이다.

최종적으로 두가지 방법을 고민하다가 2번 방법을 사용하기로 결정했다.

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/7AppleDeleteFlow.png)

그에따라 탈퇴로직은 위 다이어그램처럼 진행하게 되었다.

## 과정

---

### Client Secret 생성

---

우선 토큰을 생성하고 해제 하는 과정에서 Client Secret을 필요로 한다.

Client Secret은 개인키로 암호환한 토큰이라고 생각하면 된다.

```
{
    "alg": "ES256",
    "kid": "ABC123DEFG"
}
{
    "iss": "DEF123GHIJ",
    "iat": 1437179036,
    "exp": 1493298100,
    "aud": "https://appleid.apple.com",
    "sub": "com.mytest.app"
}
```

위 형태는 공식문서에 나온 예시이며 각 속성을 설명하자면,

헤더에는 **alg** 그리고 **kid**를 넣어줘야 한다. **alg**같은 경우는 **ES256**을 고정으로 사용하여야 하며, **kid**의 경우에는 애플 개발자 계정을 들어갔을때 **keyId**에 해당하는 부분이다.

바디의 **iss**는 **teadId**를 넣어주면 되고, **teamId**는 개발자 계정 사이트 우측상당의 값이다. **iat**와 **exp**는 차례대로 발급시간과 유효시간을 뜻한다. 발급시간은 현재 시간을 돌려주면 된다. 유효시간은 최대기한이 6개월이므로 넘지 않도록 주의하여야 한다.

**aud**는 "**https://appleid.apple.com**"는 고정값을 가지며 **sub**는 **Identifier**에 **Bundle Id**를 넣어주면 된다.

#### **코드**

---

```
class ApplePrivateKeyGenerator {
}
```

이번에도 **ApplePrivateKeyGenerator**라는 클래스를 생성해서 새로운 역할을 부여한다.

```
class ApplePrivateKeyGenerator {

    fun createClientSecret(kid: String, sub: String, teamId: String): String {
        val expirationDate = Date.from(LocalDateTime.now().plusDays(30).atZone(ZoneId.systemDefault()).toInstant())
        return Jwts.builder()
            .setHeaderParam("kid", kid)
            .setHeaderParam("alg", "ES256")
            .setIssuer(teamId)
            .setIssuedAt(Date(System.currentTimeMillis()))
            .setExpiration(expirationDate)
            .setAudience("https://appleid.apple.com")
            .setSubject(sub)
            .signWith(getPrivateKey(), SignatureAlgorithm.ES256)
            .compact()
    }
}
```

추가적으로 **createClientSecret**이라는 메서드를 만들어서 위에서 살펴보았던 **ClientSecret**을 생성한다.  특별한 점은 없고 마지막 서명을 개인키를 이용해서 하여야 한다.

```
    private fun getPrivateKey(): PrivateKey {
        val resource = ClassPathResource("")
        val inputStream: InputStream = resource.inputStream
        val privateKey = inputStream.readBytes().toString(Charsets.UTF_8)
        val pemReader = StringReader(privateKey)
        PEMParser(pemReader).use { pemParser ->
            val converter = JcaPEMKeyConverter()
            val `object` = pemParser.readObject() as PrivateKeyInfo
            return converter.getPrivateKey(`object`)
        }
    }
```

**getPrivateKey**라는 메서드를 생성해서 위쪽 개인키로 넣어주도록 하자

### Access Token 생성

---

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/8AccessToken.png)

이제 만들어진 Secret 그리고 추가적인 속성값들을 이용해서 토큰을 요청하면 된다.

위 엔드포인트로 통신하기 위해서는 4가지 인자를 필요로한다.

> 1\. clietId
> 2\. clientSecret
> 3\. grantType
> 4\. code

여기까지 왔으면 4가지 인자모두 준비되어 있을 것이다.

**clientId**의 경우에는 이전에 설정하였던 **SUB**값을 이용하면 되고 **clientSecret**은 바로전에 생성한 값을 이용, **grantType**은 요청하려는 토큰 종류에 따라 **"authorization\_code"**혹은 **"refresh\_token"**을 넣어주면 된다. 마지막으로 **code**는 사용자가 로그인시 발급받는 **A****uthorization Code**을 사용하면 된다.

```
    @PostExchange(AppleOauthConstants.CREATE_TOKEN)
    fun createAppleToken(
        @RequestParam("client_id") clientId: String,
        @RequestParam("client_secret") clientSecret: String,
        @RequestParam("grant_type") grantType: String,
        @RequestParam("code") code: String,
    ): AppleTokenResponse
```

위 설정을 바탕으로 HTTP Interface를 이용해서 요청을 하면 위코드처럼 요청을 하게 된다. 필요한 값을 반환타입 DTO로 설정을 하면된다.

### Token Revoke

---

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/9TokenRevoke.png)

최종적으로 탈퇴과정에 필요한 Token Revoke로직이다. 

Revoke Api는 토큰 생성로직과 상당히 비슷하기 때문에 코드를 재사용 하면된다.

주의하여 볼 부분은 인자로 token을 받는 부분이다. 조금전에 생성한 토큰을 token인자로 넣어주면 된다.

```
    @PostExchange(AppleOauthConstants.REVOKE_TOKEN)
    fun revokeToken(
        @RequestParam("client_id") clientId: String,
        @RequestParam("client_secret") clientSecret: String,
        @RequestParam("token") token: String,
        @RequestParam("token_type_hint") hint: String,
    ): ResponseEntity<Unit>
```

실제 코드는 위와같으며, 기존 토큰생성과 달라진점은 **Api**호출 엔드포인트와 인자로 token을 받는다는점, 그리고 탈퇴로직은 반환값을 받을 필요가 없기 때문에 **Unit**처리를 해준다는 차이가 있다.

---

여기까지 진행하면 한사이클의 애플 소셜 로그인이 완성되었다고 할수있다. 애플 소셜로그인은 레퍼런스가 다른 소셜로그인보다 부족한 점도 있고, 공식문서가 영어이며, 로직이 정형화 되어있지 않아서 개발자 입장에서 고민을 하여야 하는 부분이 많았던것 같다. 추가적으로 보안관련한 부분이 부족한것 같아 이번기회로 추가적인 공부를 해볼생각이다.

#### 참고 문헌:

[https://developer.apple.com/documentation/accountorganizationaldatasharing/creating-a-client-secret](https://developer.apple.com/documentation/accountorganizationaldatasharing/creating-a-client-secret)

[Creating a client secret | Apple Developer Documentation

Generate a signed token to identify your client application.

developer.apple.com](https://developer.apple.com/documentation/accountorganizationaldatasharing/creating-a-client-secret)

[https://velog.io/@givepro91/jjo2cyus#client\_secret-%EC%83%9D%EC%84%B1-%EB%B0%A9%EB%B2%95](https://velog.io/@givepro91/jjo2cyus#client_secret-%EC%83%9D%EC%84%B1-%EB%B0%A9%EB%B2%95)

[애플 로그인 및 탈퇴 과정

애플 로그인 및 탈퇴 과정 iOS APP 심사 중 아래와 같은 사유로 심사 리젝 응답을 받았다.

velog.io](https://velog.io/@givepro91/jjo2cyus#client_secret-%EC%83%9D%EC%84%B1-%EB%B0%A9%EB%B2%95)
