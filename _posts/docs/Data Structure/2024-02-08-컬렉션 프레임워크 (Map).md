# 자바의 컬렉션 프레임워크

---

자바의 컬렉션 프레임워크란 자료구조에서 배우는 여러가지 형태의 데이터를 저장하는 알고리즘을 구조화 하여 구현해둔 클래스이다. 쉽게 생각하면
자료구조를 모듈화 하여 사용하기 쉽게 만들어둔 자바 내부 라이브러리 이다.

자바의 컬렉션은 크게 두가지 계층 구조로 나눌수 있는데 첫번째 사진처럼 **Collection** 을 상속받는 **List**, **Queue**,
**Set** 인터페이스 구조와 아래 사진처럼 **Map**인터페이스를 가지는 구조로 나눌수가 있다.

<img src="https://media.geeksforgeeks.org/wp-content/cdn-uploads/20200811210611/Collection-Framework-2.png">

[사진 출처](https://www.geeksforgeeks.org/how-to-learn-java-collections-a-complete-guide/)

<br><br>

## Map

---

Map 인터페이스는 키와 밸류 값을 쌍으로 가지고 있는 자료구조 타입이다. 자료구조 형태이지만 자바의 컬렉션 프레임워크를 상속받지 않고
개별적인 인터페이스로 구성되어있다. 

Map 인터페이스의 주요 특징으로는
1. 키와 밸류를 한쌍으로 가진다.
2. 밸류값은 중복이 올수있지만, 키값은 중복이 존재하면 안된다.
3. 중복 키값이 발생하면 이전에 존재하던 키값을 없애고 새로운 키값과 밸류의 한쌍이 저장된다.
4. 순서가 유지 되지 않는다.


<br><br>

### HashTable

---

HahTable은 자바 초기의 레거시 클래스이다. HashTable.class 의 설명에 따르면 키와 밸류 두가지 모두에 null을 허용하지 않는다.
또한 기본적으로 동기화가 된다는 특징을 가지고 있다.

HashTable의 동작방식은 키값을 해싱을 하여 나온 값을, 배열의 인덱스로 사용하는 방식을 가지며 그러한 방식으로 값에 접근한다.

<br><br>

### HashMap

---

HashMap은 기존 HashTable 기반으로 제작한 구현체이다. HashMap 클래스의 설명에 따르면, 기존 HashTable과는 다르게
키와 밸류 모두 null을 허용한다는 특징을 가지고 있다.

HashMap은 기본으로 비동기화의 특성을 가지기 때문에 멀티쓰레드 환경에서는 고려해보아야 한다.

중복을 허용하지 않고, 순서또한 보장되지 않는다는 특징을 가지고 있다.


````java
Map<String, Integer> hashMap = new HashMap<>();
        hashMap.put("시민A", 25);
        hashMap.put("시민B", 33);
        hashMap.put("시민C", null); // 밸류 값으로 null 허용
        hashMap.put(null, 199); //키값으로 null허용
        hashMap.put(null, 255); //중복된 키값

        System.out.println(hashMap.get("시민A"));
        System.out.println(hashMap.get("시민c"));
        System.out.println(hashMap.get(null));
````

위 코드는 hashMap을 선언하고, 값을 집어넣는 코드이다. 특이한점은 밸류와 키 모두 null 이 허용된다는 것과
키값이 중복이 발생하게 되면 가장 최근에 작성된 값만 남게된다는 특징을 가지고 있다.

<br><br>

### LinkedHashMap

---

LinkedHashMap은 HashMap과 유사한 특징을 가지지만 이름에서 유추 가능하듯이 기존 Linked 시리즈 처럼 순서유지가 가능하다는 특징이있다.
아래 코드를 통해 확인 하겠다.

````java
  Map<String, Integer> hashMap = new HashMap<>();
        hashMap.put("시민A", 25);
        hashMap.put("시민B", 33);
        hashMap.put("시민C", null);

        for(String key: hashMap.keySet()){
            System.out.println(hashMap.get(key));  
        }
        // 기존 HashMap은 순서가 유지되지 않는다.

        Map<String, Integer> linkedHashMap = new LinkedHashMap<>();
        linkedHashMap.put("시민A", 25);
        linkedHashMap.put("시민B", 33);
        linkedHashMap.put("시민C", null);

        for(String key: linkedHashMap.keySet()){
            System.out.println(linkedHashMap.get(key)); 
        }
        // linkedHashMap은 순서가 유지된다.
````

위 코드를 출력을 하게 되면

**hashMap은 순서가 유지되지 않고 출력**

>33
null
25

**linkedHashMap 순서가 유지되며 출력**

>25
33
null

이를 통해 linkedHashMap은 들어온 순서대로 키와 값이 저장되는 것을 확인할 수 있다.

<br><br>

### TreeMap

---

treeMap은 바이너리 서치 트리의 한 형태로 키와 값을 가지는 형태로 이루어진 데이터를 저장한다.
treeMap은 기본적으로 정렬을 하고 키값을 기준으로 정렬이 진행된다. 

````java
Map<Integer, String> treeMap = new TreeMap<>();

        treeMap.put(2, "egg");
        treeMap.put(1, "chicken");
        treeMap.put(3, "rice");
        treeMap.put(6, "fish");
        treeMap.put(5, "fruit");

        for(Integer key : treeMap.keySet()) {
            System.out.println(treeMap.get(key));
        }
    }
````

>chicken
> 
>egg
> 
>rice
> 
>fruit
> 
>fish


TreeMap은 위 코드에서 볼 수 있듯이, 키값으로 정렬 되기 때문에 키에 있는 숫자가 작을수록 앞에 나오는 것을 확인할 수 있다.

<br><br>

## 결론

---

1. Map 인터페이스는 키와 값을 저장하는 자료구조이다.
2. 기본적으로 Map은 null을 허용하지 않고, 키에는 중복을 허용하고 순서가 보장되지 않는다.
3. 하지만 Map 구현체마다 특징이 조금 다르기 때문에 상황에 맞게 사용하면 된다.


