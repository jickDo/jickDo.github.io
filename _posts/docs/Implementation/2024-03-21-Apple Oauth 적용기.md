---
title: Apple Oauth 적용기
tags: 구현
article_header:
type: cover
---

## 시작에 앞서

---

현재 진행하고 있는 데이원 프로젝트에서 앱을 배포할 준비를 하고있었다. 플로우상 카카오 Oauth를 사용하고 있었는데 IOS에서 앱을 배포할때 다른 소셜로그인을 사용한다면, 애플 소셜로그인도 필수적으로 들어가야하며, 만약에 그렇지 못한경우 reject사유 이기 때문에 애플 Oauth를 도입하게 되었다.

## 플로우

---

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/1AppleFlow.png)

전체적인 회원가입 플로우이다. 애플 소셜 로그인의 경우에는 여타한 소셜로그인에 비해서 정형화된 느낌이 없었다. 그렇게 생각한 이유는 추후에 자세하게 설명하게 되겠지만, 토큰을 발급받는 과정이나 추가적인 검증부분이 필수가 아니기 때문이다. 즉 개발자가 상황에 맞게 필요한 부분을 맞춰 나가야 한다.

위 플로우를 요약해서 설명하게 되면


1.  사용자가 회원가입 요청을 한다.
2.  우리의 서버에서 애플 Api서버로 공개키 목록을 받아온다.
3.  공개키 목록에서 사용자 토큰과 일치하는 공개키를 식별한다.
4.  식별한 공개키로 전달받은 Identity Token의 claim을 추출한다.
5.  AccessToken 과 RefreshToken을 요청한다.
6.  사용자 회원가입에 응답한다.

요약을 하게 되면 위와같은 플로우를 가지게 되고, 5번의 경우는 선택적으로 구현가능한데 그러한 이유는 서비스 내부적인 토큰을 운용하고 있다면 그것을 이용해서 토큰으로 사용자에게 반환하면 된다.

시퀀스 다이어그램에서 Identity Token, Authorization Code요청 부분은 프론트단에서 처리하며 백엔드는  Identity Token, Authorization Code부분을 받는 부분부터 시작이라고 할수있다.

데이원 프로젝트에서는 내부 JWT토큰을 사용하고 있었기 때문에 claim에서 추출한 고유한 사용자 id값으로 토큰을 생성할 예정이다.

---

> 보다 자세한 내용은 애플 공식문서를 참고하면 되겠다.

[https://developer.apple.com/documentation/sign\_in\_with\_apple/sign\_in\_with\_apple\_rest\_api/authenticating\_users\_with\_sign\_in\_with\_apple](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/authenticating_users_with_sign_in_with_apple)

### Public Key 요청

---

플로우상 3번 과정에 해당하며, 사용자가 회원가입을 요청하고 프론트측에서 Identity Token을 정상적으로 반환하였다는 가정하에 진행하겠다.

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/2PublicKeyReq.png)

위 애플측 Api서버로 요청을 하게되면 애플측에서 여러가지의 공개키들을 반환하게 된다.  요청시 추가적인 요청값을 필요하지 않는 Api기 때문에 사진의 엔드포인트로 요청을 날리면 공개키 목록들이 반환된다.

위 Api를 포스트맨에서 간단한 Api를 만들고 전송해보았다.

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/3PublicKeyReq.png)

```
{
    "keys": [
        {
            "kty": "RSA",
            "kid": "fh6Bs8C",
            "use": "sig",
            "alg": "RS256",
            "n": "",
            "e": ""
        },
        {
            "kty": "RSA",
            "kid": "pyaRQpAbnY",
            "use": "sig",
            "alg": "RS256",
            "n": "",
            "e": ""
        },
        {
            "kty": "RSA",
            "kid": "Bh6H7rHVmb",
            "use": "sig",
            "alg": "RS256",
            "n": "",
            "e": ""
        },
        {
            "kty": "RSA",
            "kid": "lVHdOx8ltR",
            "use": "sig",
            "alg": "RS256",
            "n": "",
            "e": ""
        }
    ]
}
```

Api 호출시 위와같은 keys리스트에 json타입으로 4개의 키들이 호출된것을 확인할 수 있다. n , e값들은 식별된 퍼블릭 키에서 RSA방식 공개키를 사용하는데 사용된다. 위 코드에서는 그 부분은 지워두었다.

---

#### 실제 프로젝트 소스상에서 위 Api 호출로직을 살펴보면

```
    @GetExchange(AppleOauthConstants.GET_PUBLIC_KEYS)
    fun getApplePublicKeys(): ApplePublicKeyResponse
```

위 코드와 같은 모습이 된다. 현재는 HttpInterface 를 사용하였는데 이는 Spring6에서 추가 된 방식이다.

선언적 방식이라는 장점이 있다. 자세한 내용은 아래 공식문서를 참고하자

[https://docs.spring.io/spring-framework/reference/integration/rest-clients.html#rest-http-interface](https://docs.spring.io/spring-framework/reference/integration/rest-clients.html#rest-http-interface)

[REST Clients :: Spring Framework

WebClient is a non-blocking, reactive client to perform HTTP requests. It was introduced in 5.0 and offers an alternative to the RestTemplate, with support for synchronous, asynchronous, and streaming scenarios. WebClient supports the following: Non-blocki

docs.spring.io](https://docs.spring.io/spring-framework/reference/integration/rest-clients.html#rest-http-interface)

---

본론으로 돌아와 **@GetExchange** 로 Get요청임을 명시하고 괄호안에 조금전에 보았던 엔드포인트를 넣어주면 된다. 현재 코드에서는 엔드포인트를 아래와같이 상수처리 해두었다.

```
object AppleOauthConstants {
    const val APPLE_URL = "https://appleid.apple.com"
    const val GET_PUBLIC_KEYS = "/auth/keys"
}
```

추가적으로, Http Interface에서는 반환값을 기준으로 응답값을 파싱해주기 때문에 반환값을 **ApplePublicKeyResponse** 이라는 Dto로 설정해주었다.

```
data class ApplePublicKeyResponse(
    val keys: List<ApplePublicKey>,
)
```

```
data class ApplePublicKey(
    val kty: String,
    val kid: String,
    val use: String,
    val alg: String,
    val n: String,
    val e: String
)
```

**ApplePublicKeyResponse** 내부에 **ApplePublicKey**라는 퍼블릭키 형태를 구성하는 Dto를 구성하며, 이를**ApplePublicKeyResponse**에서 List형태로 받는다. 이렇게 이중구조로 Dto를 구성한 이유는 추후에 **ApplePublicKeyResponse** 에서 추가적인 메서드를 작성해서 퍼블릭키 식별 로직을 작성하기 위해서이다.

퍼블릭키를 요청하는 애플 공식문서는 아래 주소로 가면있다.

[https://developer.apple.com/documentation/sign\_in\_with\_apple/fetch\_apple\_s\_public\_key\_for\_verifying\_token\_signature](https://developer.apple.com/documentation/sign_in_with_apple/fetch_apple_s_public_key_for_verifying_token_signature)

[Fetch Apple’s public key for verifying token signature | Apple Developer Documentation

Fetch Apple’s public key to verify the ID token signature.

developer.apple.com](https://developer.apple.com/documentation/sign_in_with_apple/fetch_apple_s_public_key_for_verifying_token_signature)

---

### 퍼블릭키 식별

플로우 그림상 4번까지의 과정까지 진행이 되었다. 이제 5번 과정을 알아볼 차례이다.

사용자는 회원가입을 요청하고 프론트 측에서 **Identity Token** 요청하고 이를 백엔드 서버로 전달했을 것이다. 퍼블릭키 식별을 위해서는  **Identity Token** 을 필요로 한다.

우리는 이  **Identity Token** 을 기반으로 공개키 목록에서 **alg, kid** 가  **Identity Token** 에서  **alg, kid** 가 같은 키를 식별하고, 식별된 키에서 **n, e** 값을 이용해서 새로운 공개키를 생성하여야 한다. 이 생성된 공개키는 이제 **Identity Token**  의 **claim**을 추출하는게 사용될것이다.

조금 과정이 복잡하기 때문에 이를 순서로 요약하면,

1.  **Identity Token** 의 헤더를 파싱한다.
2.  파싱된 헤더의 **alg, kid** 와 공개키 목록에서 **alg, kid**가 같은것이 있을건데 그 키를 뽑아낸다.
3.  뽑아낸 키에서 n,e를 이용해서 새로운 공개키를 생성한다.
4.  생성된 공개키는 **Identity Token**을 복호화하는데 사용될 수 있다.

차례대로 알아보자

### Identity Token 파싱

---

우선 **JwtParser**라는 클래스를 생성한다. 토큰을 파싱하는 별도의 책임을 가지기 때문에 **JwtParser**에 책임을 위임하기 위해서이다. 그리고 헤더를 파싱하는 메서드를 하나 생성한다.

```
    fun parseHeaders(identityToken: String): Map<String, String> {
        try {
            val encodedHeader = identityToken.split(Regex(IDENTITY_TOKEN_VALUE_DELIMITER))[HEADER_INDEX]
            val decodedHeader = String(Base64.getUrlDecoder().decode(encodedHeader))
            return OBJECT_MAPPER.readValue(decodedHeader)
        } catch (e: Exception) {
            throw RuntimeException(e)
        }
    }
```

```
    companion object {
        private const val IDENTITY_TOKEN_VALUE_DELIMITER = "\\."
        private const val HEADER_INDEX = 0

        private val OBJECT_MAPPER = jacksonObjectMapper()
    }
```

코드의 구조와 상수선언은 위와같은데, **IDENTITY\_TOKEN\_VALUE\_DELIMITER**와 **HEADER\_INDEX**의 설정은 **JWT**토큰의 구조를 알고있어야 파싱할 수 있다.

![](https://raw.githubusercontent.com/jickDo/picture/master/Implementation/Apple/4JWT.png)

**JWT**토큰은 위 사진과 같이 헤더, 페이로드, 시그니처로 나눠지게 되고 우리가 필요한 부분은 **Identity Token**의 헤더이기 때문에 "."을 기준으로 split하고, 인덱스가 시작인 "0"을 파싱한것이다. 추가적으로 로직에서 바로 "**\\\\.**" 혹은 "**0**"을 넣게 되면 이해하기 어려운 **매직넘버** 가 되기 때문에, 이를 상수처리를 한것이다.

**OBJECT\_MAPPER**의 경우에는 계속해서 재사용되는 객체이기 때문에 이를 싱글톤으로 처리해서 객체가 계속 생성되는 것보다, 재사용되는 것이 좋다고 판단하여 싱글톤처리를 하였습니다.

### 공개키 식별

---

다음은 두번째 과정인 **Identity Token**과 공개키 리스트에서 적절한 공개키를 식별하는 과정입니다.

이전에 **ApplePublicKeyResponse**에서 추가적인 퍼블릭키 식별로직을 추가하기로 하였다.

```
data class ApplePublicKeyResponse(
    val keys: List<ApplePublicKey>,
) {
    fun getMatchedKey(alg: String?, kid: String?): ApplePublicKey {
        return keys.firstOrNull { it.alg == alg && it.kid == kid }
            ?: throw NotMatchedException()
    }
}
```

이전 로직에서 **getMatchedKey**라는 메서드를 추가한다. 이는 공개키 리스트를 순회하며 매개변수로 받은 **alg,kid**가 공개키와 같은 경우 그 키를 반환하는 로직이다. 만약에 같은 경우가 없는 경우 코틀린의 **firstOrNull**을 이용해서 **null**을 반환받고 엘비스 연산자를 이용해서 예외처리를 진행하였다.

여기까지 하면 식별된 **공개키**와 **Identity Token**의 헤더가 준비 되었다. 이제 실제로 **Identity Token**을 복호화할 키를 생성하여야 한다.

### 복호화에 사용할 퍼블릭 키 생성

---

이제 새로운 퍼블릭키를 만든 클래스를 생성한다.

```
class ApplePublicKeyGenerator {

}
```

이름은 ApplePublicKeyGenerator로 애플의 퍼블릭키를 만드는 클래스임을 명시하였다.

```
fun generatePublicKey(
	tokenHeaders: Map<String, String>,
	applePublicKeys: ApplePublicKeyResponse,
): PublicKey {
	val publicKey = applePublicKeys.getMatchedKey(tokenHeaders["alg"], tokenHeaders["kid"])
    return getPublicKey(publicKey)
}
```

바로 전에 만들어두었던 **ApplePublicKeyResponse**의 **getMatchedKey** 메서드를 사용하여 새로운 키를 생성하는 로직을 구성하였고, Dto의 메서드와 public 생성하는 메서드를 연결하는 로직이다. 

```
private fun getPublicKey(publicKey: ApplePublicKey): PublicKey {
    val nBytes: ByteArray = Base64.getUrlDecoder().decode(publicKey.n)
    val eBytes: ByteArray = Base64.getUrlDecoder().decode(publicKey.e)
	val publicKeySpec = RSAPublicKeySpec(
		BigInteger(1, nBytes),
		BigInteger(1, eBytes),
    )
	val keyFactory = KeyFactory.getInstance(publicKey.kty)
	return keyFactory.generatePublic(publicKeySpec)
    }
```

이부분은 실제 **PublicKey**를 만드는 로직이고, 외부에서 사용될 가능성이 없다고 판단하여 **pirvate**으로 캡슐화를 하였다. 식별된 애플의 퍼블릭키에서 **n,e**를 추출하여 이를 디코딩한다. 애플에서 넘어온 퍼블릭키의 요소들은 인코딩 되어있기 때문에 실제값을 사용하기 위해서는 디코딩을 진행하여야 하며, n그리고 e는 퍼블릭키를 만드는 재료이다. 자세한 내용은 **RSA 암호화 방식**을 찾아보시는 것을 추천한다.

### Identity Token 검증

---

Identity Token에서 사용자의 claim을 추출하기전 애플에서 Identity Token의 유효성을 검증하라고 합니다.

> 1\. Verify the JWS E256 signature using the server’s public key
> 2\. Verify the nonce for the authentication
> 3\. Verify that the iss field contains https://appleid.apple.com
> 4\. Verify that the aud field is the developer’s client\_id
> 5\. Verify that the time is earlier than the exp value of the token

애플에서 말하는 5가지의 유효성은 위와같으며 1번과정은 퍼블릭키 생성과정에서 진행되었습니다.

유효성 검증은 새로운 역할을 담당하기 때문에 **AppleClaimsValidator**라는 새로운 클래스를 생성했다.

```
@Component
class AppleClaimsValidator(
    @Value("\${}") private val iss: String,
    @Value("\${}") private val clientId: String,
    @Value("\${}") nonce: String,
)
```

2번부터 4번까지 필요로 하는 검증 값을 미리 환경변수 설정해서 불러오는 식으로 만들었다.

```
    private val nonce: String = EncryptUtils.encrypt(nonce)

    fun isValid(claims: Claims): Boolean =
        claims.issuer.contains(iss) &&
            claims.audience == clientId &&
            claims[NONCE_KEY, String::class.java] == this.nonce

    companion object {
        private const val NONCE_KEY = "nonce"
    }
```

nonce값은 프론트측에서 특정 문자열을 암호화하여 보내고, 이를 서버측에서 같은 암호화를 진행해 대조해보는 방식이다. clientId와 발행자또한 claim에서 비교를 통해 유효성 검증을 진행하자 자세한 검증로직은 애플 공식문서를 참고하는 것을 추천한다.

[https://developer.apple.com/documentation/sign\_in\_with\_apple/sign\_in\_with\_apple\_rest\_api/verifying\_a\_user](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user)

[Verifying a user | Apple Developer Documentation

Check the validity and integrity of a user’s identity token.

developer.apple.com](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user)

### Claim 추출

---

최종적으로 우리는 사용자의 claim이 들어있는 토큰과 이를 복호화할 퍼블릭키를 가지게 된 셈이다. 이제 복호화를 진행하여 사용자의 정보를 추출하면 6번 과정이 끝이난다. 이전에 작성했던 **JwtParser** 클래스에서 프론트측으로 지급받은 **Identity Token**그리고 이전에 생성한 **퍼블릭키**를 이용해서 토큰을 복호화하는 로직이다. 이부분은 특별한 점이 없기 때문에 코드만 남겨두겠다.

```
    fun parsePublicKeyAndGetClaims(idToken: String, publicKey: PublicKey): Claims {
        try {
            return Jwts.parserBuilder()
                .setSigningKey(publicKey)
                .build()
                .parseClaimsJws(idToken)
                .body
        } catch (e: JwtException) {
            throw RuntimeException()
        }
    }
```

**이부분에서 주의해야 하는점이 있는데**, 카카오 Oauth처럼 생성된 토큰을 기반으로 카카오 서버에 사용자 정보를 추출하는 것이 아닌, 개발자가 추출된 claim에서 사용자 정보를 직접 추출해야 한다.

```
val claims = validateAndCreateClaims(loginRequest)
validateClaims(claims)
return AppleOauthRequest(
	claims.subject,
	claims["name", String::class.java],
	claims["email", String::class.java],
)
```

추출은 사용자가 직접 뽑아내서 DTO로 반환하는 방식이던 필요한 값만 리턴하던 본인의 선택사항에 맞게 진행하면 된다. 

## 선택지

---

여기까지 하면, 필요한 사용자의 정보를 추출할 수 있어 그것을 기반으로 서비스 내부의 **JWT**토큰으로 만들어 사용하던지, 추가적으로 애플에서 **AccessToken**과 **RefreshToken**을 추가적으로 받아 진행할 수 있다. 데이원에서는 내부 **JWT**토큰을 이용하고 있기 때문에 추가적인 로직은 진행하지 않기로 했다.

참고 문헌:
[애플 공식문서](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user)

[FeignClient 이용한 애플 Oauth 구현](https://kth990303.tistory.com/437)

[JWT에 대한 내용](https://velog.io/@vamos_eon/JWT%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%B8%EA%B0%80-%EA%B7%B8%EB%A6%AC%EA%B3%A0-%EC%96%B4%EB%96%BB%EA%B2%8C-%EC%82%AC%EC%9A%A9%ED%95%98%EB%8A%94%EA%B0%80-1)
