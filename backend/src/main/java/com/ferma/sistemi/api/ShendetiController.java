package com.ferma.sistemi.api;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ShendetiController {

    @GetMapping("/api/shendeti")
    public Map<String, String> shendeti() {
        return Map.of(
                "statusi", "ok",
                "projekti", "Sistemi per Menaxhimin e Fermereve dhe Produkteve Bujqesore"
        );
    }
}
