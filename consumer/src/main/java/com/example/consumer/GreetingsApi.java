package com.example.consumer;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class GreetingsApi {


    @GetMapping("/")
    Greeting greet() {
        return new Greeting("Hello World!");
    }

    record Greeting(String content) {}
}
