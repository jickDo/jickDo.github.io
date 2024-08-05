---
title: StringBuilder의 모든것!
tags: 자바 문법
article_header:
type: cover
---

# StringBuilder 톺아보기

---

오늘 공부한 내용은 StringBuilder에 대한 내용이다. 최근 String의 메서드나 String그 자체의 불변성, String constant pool같은 메모리 사용 부분에 대해서
공부를 했었다. 알고리즘을 공부를 하다보면 문자열을 사용할 경우가 많고, 그러다 보면 의도치 않게 메모리를 많이 잡아 먹는데 그것을 해결해줄 대안으로 StringBuilder를 공부하게 되었다.


<br><br>

## StringBuilder란?

---

>A mutable sequence of characters.
>This class provides an API compatible with StringBuffer, but with no guarantee of synchronization.
>This class is designed for use as a drop-in replacement for StringBuffer in places where the string buffer was being used by a single thread (as is generally the case).
>Where possible, it is recommended that this class be used in preference to StringBuffer as it will be faster under most implementations.

위 문장은 StringBuilder.java의 공식문서의 가장 최상단 설명이며, 그 설명은
> '문장은 변경가능 하며, 동기화가 보장되지 않는 StringBuffer이다'
>
> 또한, 단일 스레드 에서 StringBuffer의 대체 목적으로 설계 되어 대부분의 경우는 StringBuffer보다 빠르다는 점을 말한다.

쉽게 요약하자면 String클래스를 변경가능 하고 추가 데이터를 잡아먹지 않는 방식의 변경을 가할수 있으며, StringBuffer의 멀티스레드 환경에서
대채제로 개발되어 왠만한 환경은 StringBuilder가 빠르다는 점을 말하고 있다.

**알고리즘 문제는 속도와 메모리 사용의 중요성이 있기 때문에 왠만해서는 String을 변경하게 된다면 StringBuilder를 사용해야 할것같다.**


<br>

또한 한가지 특징으로

> Every string builder has a capacity.
>As long as the length of the character sequence contained in the string builder does not exceed the capacity, it is not necessary to allocate a new internal buffer.
> If the internal buffer overflows, it is automatically made larger.

위 문장은 스트링 빌더의 용량이 정해져있고, 이를 초과하면 그때서야 추가 용량을 자동으로 할당받는 점을 말하고 있다.

<br><br>

## StringBuilder()의 선언

---

>Constructs a string builder initialized to the contents of the specified string. The initial capacity of the string builder is 16 plus the length of the string argument.
Params:
str – the initial cont


>StringBuider는 생성자에 문자를 받을수 있고, 그 문자의 길이에 16을 더한 값이 초기 StringBuilder의 크기가 된다.

````java
StringBuilder sb = new StringBuilder();
StringBuilder sb2 = new StringBuilder("임직찬");
````
위 두가지 경우가 StringBuilder의 초기선언이며 클래스 이기 때문에 new를 통해서 할당해야한다.

<br><br>

### StringBuilder 활용1 (내장 메서드)

---

### append()

append는 StringBuilder에 특정한 값을 추가하는 메서드이다. 여기서 특정한 값이란?

int , char, boolean, double, String 등등 많은 자료형을 지원하고 있다. 신기하게 어떤 자료형을 인수로 넣던간에
리턴은 StringBuilder로 나온다는 점이다. 아래 코드를 통해 예시를 보겠다.

````java
StringBuilder sb = new StringBuilder("임직찬 ");
int age = 24;
sb.append(age);
````

위 코드에 대한 답은

>임직찬 24

으로 나오게 된다. 즉 어떤 자료형의 인수로 넣던간에 편리하게 StringBuilder에 붙여주는 메서드이다.


<br><br>

### StringBuilder 활용2 (내장 메서드)

---

### delete()

delete()는 이름그대로 무언가를 삭제 하는 메서드이다. 특별 한 점은 없고 인수를 시작과 끝 인덱스를 받는다는 것이다.
이전 substring처럼 첫 인덱스를 안써주어도 작동하는것이 아니라 꼭, 시작 끝 인덱스를 명시하여야 한다.

아래 코드는 이전의 코드를 이어서 사용하였다.

````java
sb.delete(4,6);
````

> 임직찬

인덱스 4부터 5까지 StringBuilder에서 값을 삭제하는 메서드이다.

<br>

### deleteCharAt()

이전 delete와 같은 기능을 하지만, 차이점으로는 기존 delete는 구간을 자르는 것이지만 deleteChatAt은 인수로
인덱스를 받아서 그부분을 도려내는 기능을 한다.

````java
sb.deleteCharAt(0);
````

기존 **임직찬 24**의 결과에서 위코드를 시행하면

>직찬 24

가 나온다. 0인덱스에 해당하는 '임'을 추출해버린것이다.


<br><br>

### StringBuilder 활용3 (내장 메서드)

---

### replace()

replace는 '대체하다.'라는 단어 이름답게 특정한 구간을 인수로 넣은 문자열로 대체하는 기능을 합니다.

아래 코드를 통해 예시를 보면

````java
StringBuilder sb = new StringBuilder("임*직*찬");
sb.replace(0,4,"*");
````

replace는 인수를 3개 받습니다. 먼저, 시작인덱스 그리고 끝인덱스 이 두개의 인수로 인해 구간을 결정하고 마지막 문자열 인수를
입력받아 특정구간을 3번째 인수 문자열로 바꾸어 버립니다. 따라서 위코드의 결과는

>*찬

이됩니다.

<br><br>

### StringBuilder 활용4 (내장 메서드)

---

### insert()

insert는 이름그대로 특정 값을 넣는 메서드입니다. 아래의 코드를 통해 설명하겠습니다.

````java
StringBuilder sb = new StringBuilder("임직찬");
sb.insert(1,"*");
````

위 코드는 "임직찬"이라는 문자열에 "*"을 집어넣는 기능입니다. insert는 인수로 인덱스 값과 집어넣고자 하는 문자나 정수 실수 등등
값을 받습니다. 위 코드의 경우는 *이라는 문자열을 1번 인덱스에 집어넣은 것입니다.

> 임*직찬

결과는 1번 인덱스 "직" 의 자리에 "*"이 끼어들고 "직"은 한칸 밀리는 것을 볼수 있습니다.

<br><br>

### StringBuilder 활용5 (내장 메서드)

---

### indexOf()

indexOf의 경우는 이전에 공부해서 인수만 확인하고 넘어간다.

1. indexOf("문자열");
2. indexOf("문자열",시작인덱스)

1번의 경우는 기존의 공부했던 indexOf와 같은 기능을 하지만 2번의 경우는 유심히 볼 가치가 있어보인다.

첫번째 인수 문자열을 받아 검색하여 가장 먼저 나오는 문자열 인덱스를 반환하는 기능까지는 유사하지만, 검색의 시작 인덱스를
지정할 수 있다. 알고리즘 문제를 풀다보면 검색 시작 인덱스를 지정해주는 경우가 있고, 번거로운 부분인데 저 메서드를 사용한다면 쉽게
해결가능 해보인다.

<br>

### lastIndexOf()

indexOf의 변형 버전이고 이름에서 알수 있듯이 뒤에서 부터 검색을 한다. 그것말고는 특별한 기능은 없다.

<br><br>

## 결론

---

1. StringBuilder은 String 메모리 사용에 보안을 위해 사용
2. StringBuffer의 대용으로 나왔지만, 멀티 쓰레드 환경이 아니라면 StringBuilder가 빠름
3. StringBuilder의 내장 메서드는 유용한것이 많아 알고리즘 풀때 이용해볼것


