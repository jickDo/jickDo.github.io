---
title: 효율적인 공통관심사 처리
tags: 스프링 로깅
article_header:
type: cover
---

> 이 포스팅을 하게 된 계기
>

스프링부트에서 토큰으로 인가처리를 하는 로직을 작성하던 중, **'인가'**라는 **'공통관심사'**를 효율적으로 처리해 보고 싶어서 리서치를 하게 되었습니다.

---

### **공통관심사(Cross-Cutting-Concerns)**

공통 관심사란 비즈니스 로직 전반에 존재하며 메인기능(Core Concerns)이 아닌 부분들이라고 할 수 있습니다.

공통관심사는 핵심 로직은 아니지만, 빠져서는 안 될 로깅이나, 인증 혹은 인가와 같은 일들을 칭합니다.

이들은 비즈니스 로직 전반에 존재하며, 메인기능과 연결되어 있기 때문에, 시스템의 설계와 구현에서 깔끔하게 분리할 수 없는 문제가 있습니다. 이러한 문제는 코드의 중복이나 독립적인 로직과의 거리가 멀어져 의존성 문제가 생기며, 따라서 유지보수 관점에서 문제가 생길 수 있습니다.

이를 해결하기 위해 스프링에서는 

**1\. 필터**

**2\. 인터셉터**

**3\. AOP**

를 고려하여 설계할 수 있습니다.

---

### **전체적인 흐름**

![](https://raw.githubusercontent.com/jickDo/picture/master/Spring/효율적인 공통관심사 처리: Filter, Interceptor, AOP/1전체적인흐름.png)

필터, 인터셉터, AOP의 전체적인 흐름이며 이들은 실행방식, 순서, 영역등의 차이가 있습니다.

필터와 인터셉터의 경우는 Servlet단위에서 실행되는 반면 AOP의 경우 메서드 앞에서 Proxy의 형태로 실행이 됩니다.

또한 요청에 대한 실행 순서 또한 필터가 가장 빠르며 그다음 인터셉터 AOP를 거쳐 컨트롤러에서 메서드가 실행된 다음 역순으로 나가게 됩니다.

속해있는 범위 관점에서는 필터는 웹 컨테이너의 영역에 속해있지만, 인터셉터와 AOP의 경우는 스프링 영역에 속해있다는 차이점이 존재합니다. 

---

### **필터 (Filter)**

```
Dispatcher Servlet에 요청이 전달되기 전 / 후에 url 패턴에 맞는
모든 요청에 대해 부가 작업을 처리할 수 있는 기능을 제공한다.
```

![](https://raw.githubusercontent.com/jickDo/picture/master/Spring/효율적인 공통관심사 처리: Filter, Interceptor, AOP/2필터.png)

필터는 요청과 응답을 걸러서 가공하는 역할을 하게 됩니다. 스프링 Context의 범위가 아닌 WebContext의 범위에 속해있는 Filter의 경우는 spring의 자원을 사용할 수 없다는 단점이 존재합니다.

하지만 필터를 사용하는 이유는 Dispatcher Servlet보다 요청을 먼저 받기 때문에 스프링에 들어가는 전역적인 설정에 관여할 수 있고, XSS(Cross-Site-Scripting)와 같은 취약점을 보안할 수 있습니다. 여기서 전역적인 설정이란 인코딩처리, CORS, Log처리와 같은 예시가 있습니다.

---

### **인터셉터 (Interceptor)**

```
Dispatcher Servlet이 Controller를 호출하기 전 / 후에 인터셉터가 끼어들어 요청과 응답을
참조하거나 가공할 수 있는 기능을 제공한다.
```

![](https://raw.githubusercontent.com/jickDo/picture/master/Spring/효율적인 공통관심사 처리: Filter, Interceptor, AOP/3인터셉터.png)

인터셉터는 필터와 다르게 스프링 Context범위 안에 존재하며, 이러한 점 때문에 스프링의 자원에 접근할 수 있다. 필터는 Dispatcher Servlet의 요청과 응답을 가로채는 역할을 했었다면, 인터셉터의 경우는 Dispatcher Servlet이 뱉어내는 요청을 가로채어 가공 후 컨트롤러에 전달하는 역할을 하게 된다.

인터셉터는 여러 개를 사용할 수 있고 로그인 체크, 권한체크, 프로그램 실행시간 계산작업 로그확인 등의 업무처리에 사용하게 된다.

---

### **AOP (Aspect Oriented Programming)**

```
AOP는 공통적인 관심사를 Aspect로 만들어 모듈화를 통해
코드 재사용성을 올리겠다는 취지이다.
```

![](https://raw.githubusercontent.com/jickDo/picture/master/Spring/효율적인 공통관심사 처리: Filter, Interceptor, AOP/4AOP.png)

**AOP** (Aspect Oriented Programming)는 **OOP** (Object-Oriented Programming)의 관점에서 더 이상 중복을 줄일 수 없을 때, 문제들을 관점(Aspect)으로 바라보고 **핵심적인 관점**, **부가적인 관점**으로 그것들을 나누어 핵심적인 로직에서 부가적인 로직을 분리하고, 분리된 Aspect를 코드 전반에서 재사용하는 방식이다.

---

### **AOP의 키워드**

#### **◎  Aspect**

여러 곳에서 쓰이는 공통 관심사를 모듈화 한 것

#### ****◎** Target**

Aspect가 적용되는 곳

#### ****◎**  Advice**

실질적으로 부가기능을 담은 구현이면서 Aspect가 무엇을 언제 할지 정의한다.

#### ****◎**  Joint Point**

Advice가 적용되는 때를 말한다. 다른 AOP 프레임워크와는 달리 Spring에서 메서드 JointPoint만 제공한다.

메서드 실행 전 혹은 실행 후라고 생각하면 편하다.

#### ****◎**  Point Cut**

Advice가 실행되는 지점이다. AspectJ pointcut문법을 이용해서 지점을 설정할 수도 있고, 커스텀 어노테이션을 생성하여 어노테이션 명을 써주는 방법도 있다.

---

### **사용법**

```
@Aspect
@Component
class GetIdFromTokenAspect(
    private val jwtTokenProvider: JwtTokenProvider,
) {

    @Around("@annotation(GetIdFromToken)")
    fun authorizationToken(joinPoint: ProceedingJoinPoint): Any? {
        val request = joinPoint.args.filterIsInstance<HttpServletRequest>().firstOrNull()
            ?: throw BaseException(BaseExceptionCode.REQUEST_NOT_FOUND)

        val authorizationHeader = request.getHeader("Authorization")
            ?: throw BaseException(BaseExceptionCode.AUTHORIZATION_HEADER_NULL)

        if (!authorizationHeader.startsWith("Bearer ")) {
            throw BaseException(BaseExceptionCode.INVALID_TOKEN_PREFIX)
        }

        val token = authorizationHeader.substring(7)
        val userId = jwtTokenProvider.getPayload(token)
        request.setAttribute("userId", userId)
        return joinPoint.proceed()
    }
}
```

위 코드는 전체적인 토큰 인가에 관한 하나의 Aspect이며, 이것을 분리하면서 설명하여 AOP에 대해 조금 더 자세히 알아보겠습니다.

---

#### **↓ 커스텀 어노테이션 생성**

```
@Target(AnnotationTarget.FUNCTION, AnnotationTarget.VALUE_PARAMETER)
@Retention(AnnotationRetention.RUNTIME)
annotation class GetIdFromToken
```

커스텀 어노테이션은 **AOP**사용에 있어서 필수는 아니지만, **Aspect**의 접근 지점을 선언할 때 **AspectJ pointcut** 문법대신 커스텀 어노테이션을 사용함으로써 편한 **pointcut** 선언을 할 수 있습니다.

#### **↓ Aspect선언부**

```
@Aspect
@Component
class GetIdFromTokenAspect(
    private val jwtTokenProvider: JwtTokenProvider,
)
```

**@Aspect:** 이 어노테이션은 클래스가 AOP의 Aspect임을 나타내는 부분입니다.

**@Component:** 클래스를 스프링 빈에 등록합니다.

#### **↓ Aspect의 실행 위치와 시점**

```
    @Around("@annotation(GetIdFromToken)")
```

**Adivce**가 실행되는 방법과 시점을 나타내는 다섯 가지의 어노테이션이 존재합니다.

---

| 매서드 |   |
| --- | --- |
| @Before | 대상 메서드 전에 실행되는 어드바이스(Advice)이지만, 예외를 던지지 않는 한 조인 포인트로의 실행 흐름을 막을 수 없는 어드바이스 |
| @AfterReturning | 대상 메서드가 정상적으로 완료된 후에 실행될 어드바이스: 예를 들어, 메소드가 예외 없이 반환하는 경우 |
| @AfterThrowing | 대상 메서드가 예외를 던지면서 종료될 경우 실행될 어드바이스 |
| @After | 대상 메서드가 어떤 방식으로 종료되든(정상적인 반환 또는 예외적인 반환) 무관하게 실행될 어드바이스." |
| @Around | 대상 메소드 호출 전후에 사용자 정의 동작을 수행할 수 있습니다. 또한 조인 포인트로 진행할지, 자체 반환 값으로 조언받은 메소드 실행을 단축할지 또는 예외를 던질지를 결정하는 책임도 가지고 있습니다 |

여기서 주목해야 할 부분은 **@Around**입니다.

**@Around** 어노테이션의 경우 사실상 나머지 메서드를 전부 포괄하는 개념이기도 하며, 특수한 **ProceedingJoinPoint**구현체를 사용할 수 있습니다. **@Around** 어노테이션은 타깃메서드의 실행을 가로챈 다음 자신의 어드바이스를 실행하는 기능을 하게 됩니다. 하지만 **Around**의 어드바이스 실행 이후 원래 실행 되었어야 할 타깃메서드는 다시 실행될 방법이 없습니다. 이러한 점 때문에 스프링 컨테이너는 타깃 메서드에 관한 정보를 **Advice**로 넘겨 주어야 하며, 그것을 받는 것이 **ProceedingJoinPoint**입니다.

**ProceedingJoinPoint**는 JoinPoint의 하위 타입이며,

**JoinPoint** 인터페이스의 대표적인 기능은 다음과 같습니다.

-   getArgs() : 메서드 인수 반환
-   getThis() : 프록시 객체 반환
-   getTarget() : 대상 객체 반환
-   getSignature() : 조언되는 메서드에 대한 설명 반환
-   toString() : 조언되는 방법에 대한 유용한 설명 인쇄

다른 메서드의 경우는 반환 타입이 **void**인 반면에 **@Around** 어노테이션은 반환타입이 **Object**이며, **ProceedingJoinPoint**구현체 만의 메서드인 **proceed()**를 사용할 수 있습니다.

**proceed()**는 처음에 받은 **ProceedingJoinPoint**를 타겟메서드로 반환하는 기능을 하며, 그전에 **JoinPoint**의 기능을 이용해서 반환값을 조작 후 반환이 가능하게 됩니다.

**Around**를 제외한 다른 메서드의 경우는 **proceed**를 사용하지 않아도 알아서 타깃메서드를 찾아가는 특징이 있지만, 입력이나 반환값에 대해 조작을 못한다는 점이 있습니다.

여기까지만 본다면 **@Around** 어노테이션을 사용하는 게 가장 좋아 보이지만, 스프링 공식문서에는 이렇게 적혀있습니다.

>  Spring AOP는 AspectJ처럼 다양한 어드바이스 타입을 제공하기 때문에, 필요한 동작을 수행할 수 있는 가장 약한 어드바이스 타입 사용을 권장합니다. 예를 들어, 메서드의 반환 값으로 캐시를 업데이트하는 것만 필요하다면, 어라운드 어드바이스보다 after returning 어드바이스를 구현하는 것이 더 좋습니다.

즉 @**Adivce**로 모든 기능을 구현할 수 있다고 그것을 사용하는 것보다, 적재적소에 필요한 기능을 찾아서 쓰라는 말을 하고 있습니다. 더군다나 **@Adivce**로 구현하였을 때 **proceed()**를 제외하여 개발을 하는 오류를 범할 가능성이 있기 때문에, 가능하다면 가장 간단한 모습의 구현을 추천하고 있습니다.

#### **본론으로 돌아와서**

```
    @Around("@annotation(GetIdFromToken)")
```

결국 타깃 메서드 실행 전, 후로 **Adivce**를 실행하는데, 뒤쪽에 붙은 **GetIdFromToken**이 달린 메서드 아래를 타깃메서드로 잡으라는 내용의 코드입니다.

**@Around** 뒤쪽 부분은 **AspectJ pointcut** 문법을 사용하여 위치를 지정하여도 되지만, 위 코드처럼 커스텀 어노테이션을 지정하는 것으로 타깃메서드의 위치를 지정해 줄 수 있습니다.

#### **↓ Advice**

```
    fun authorizationToken(joinPoint: ProceedingJoinPoint): Any? {
```

**ProceedingJoinPoint**를 매개변수로 받는 것을 볼 수 있으며, 이는 타깃메서드에 대한 정보를 가지고 오게 됩니다. 자세한 설명은 위쪽에서 하였기 때문에 생략하겠습니다.

#### **↓ Advice 매인 로직**

```
val request = joinPoint.args.filterIsInstance<HttpServletRequest>().firstOrNull()
            ?: throw BaseException(BaseExceptionCode.REQUEST_NOT_FOUND)

        val authorizationHeader = request.getHeader("Authorization")
            ?: throw BaseException(BaseExceptionCode.AUTHORIZATION_HEADER_NULL)

        if (!authorizationHeader.startsWith("Bearer ")) {
            throw BaseException(BaseExceptionCode.INVALID_TOKEN_PREFIX)
        }

        val token = authorizationHeader.substring(7)
        val userId = jwtTokenProvider.getPayload(token)
```

**request**를 타깃메서드(joinPoint 매개변수)의 정보중 **HttpServletRequest**에 관한 것만 필터링해서 변수로 담았습니다. 이는 아래쪽에서 데이터를 **set** 해서 **proceed** 하기 위함입니다. 

**Adivce**의 토큰 인가에 대한 내용은 이번 포스팅과 관련이 없어서 생략하고 넘어가겠습니다.

```
request.setAttribute("userId", userId)
        return joinPoint.proceed()
    }
}
```

**HttpServletRequest**로 필터링된 **request**에 토큰에서 추출한 **userId**를 담아서 타깃메서드로 다시 리턴하는 코드입니다.

이렇게 되면 타깃메서드는 그것을 받아 **userId**를 확인해 볼 수 있습니다.

레퍼런스:

[https://docs.spring.io/spring-framework/docs/2.5.5/reference/aop.html](https://docs.spring.io/spring-framework/docs/2.5.5/reference/aop.html)

[https://goddaehee.tistory.com/154](https://goddaehee.tistory.com/154)

[https://dev-coco.tistory.com/173](https://dev-coco.tistory.com/173)
