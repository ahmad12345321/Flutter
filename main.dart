// ==========================
// Dart Complete Concepts
// ==========================

import 'dart:async';

// --- Custom Exception ---
class MyCustomException implements Exception {
  final String message;
  MyCustomException(this.message);
  @override
  String toString() => "MyCustomException: $message";
}

// --- OOP Example ---
class Person {
  String name;
  int age;

  // Default Constructor
  Person(this.name, this.age);

  // Named Constructor
  Person.guest() : name = "Guest", age = 0;

  // Getter & Setter
  String get info => "$name is $age years old";
  set setAge(int value) => age = value;

  void greet() => print("Hello, my name is $name");

  // Static Member
  static String species = "Human";
}

class Student extends Person {
  int rollNo;
  Student(String name, int age, this.rollNo) : super(name, age);

  @override
  void greet() => print("Hi, I'm student $name with roll no. $rollNo");
}

// Abstract Class
abstract class Shape {
  double area();
}

class Circle extends Shape {
  double radius;
  Circle(this.radius);
  @override
  double area() => 3.14 * radius * radius;
}

Future<void> main() async {
  // ======================
  // Variables & Constants
  // ======================
  var x = 10;
  final y = 20;
  const z = 30;
  print("x=$x, y=$y, z=$z");

  // Null Safety
  String? nullableVar;
  nullableVar = "I am not null now!";
  print(nullableVar);

  // String Interpolation
  String name = "Ahmad";
  print("Hello $name, length=${name.length}");

  // ======================
  // Control Flow
  // ======================
  if (x > 5) {
    print("x is greater than 5");
  } else {
    print("x is small");
  }

  switch (x) {
    case 5:
      print("x is five");
      break;
    case 10:
      print("x is ten");
      break;
    default:
      print("unknown value");
  }

  for (var i = 0; i < 3; i++) {
    print("For loop: $i");
  }

  int j = 0;
  while (j < 2) {
    print("While loop: $j");
    j++;
  }

  // ======================
  // Functions
  // ======================
  int add(int a, int b) => a + b;
  print("Sum: ${add(3, 4)}");

  void greetUser({String name = "User"}) {
    print("Welcome $name");
  }
  greetUser(name: "Ali");

  var list = [1, 2, 3];
  list.forEach((num) => print("Number: $num"));

  // Higher Order Function
  int operate(int a, int b, int Function(int, int) op) => op(a, b);
  print(operate(5, 3, (a, b) => a * b));

  // ======================
  // Collections
  // ======================
  List<int> nums = [1, 2, 3, ...[4, 5]];
  Set<String> fruits = {"Apple", "Mango", "Apple"};
  Map<String, int> ages = {"Ali": 20, "Sara": 22};

  print(nums);
  print(fruits);
  print(ages);

  // Collection if/for
  var filtered = [for (var n in nums) if (n % 2 == 0) n];
  print(filtered);

  // ======================
  // OOP Usage
  // ======================
  var p1 = Person("Bilal", 25);
  p1.greet();
  print(Person.species);

  var s1 = Student("Usman", 20, 101);
  s1.greet();

  var circle = Circle(5);
  print("Circle Area: ${circle.area()}");

  // ======================
  // Exception Handling
  // ======================
  try {
    throw MyCustomException("Something went wrong!");
  } catch (e) {
    print("Caught error: $e");
  } finally {
    print("Finally block executed");
  }

  // ======================
  // Asynchronous
  // ======================
  Future<String> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    return "Data fetched!";
  }

  print("Fetching...");
  String data = await fetchData();
  print(data);

  // Stream Example
  Stream<int> numberStream() async* {
    for (int i = 1; i <= 3; i++) {
      await Future.delayed(Duration(milliseconds: 500));
      yield i;
    }
  }

  await for (var value in numberStream()) {
    print("Stream value: $value");
  }
}
