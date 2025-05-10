package com.example.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class MyCiCdAppApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyCiCdAppApplication.class, args);
    }
    @GetMapping("/")
    public String hello() {
        return "Hello from rahul";
    }
}