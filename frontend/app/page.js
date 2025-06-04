"use client";
import { useState } from "react";
import styles from "./page.module.css";

export default function Home() {
  // inicializar uma variável reativa que vai receber o resultado da requisição
  const [resultado, setResultado] = useState("Nenhuma requisição foi realizada...");

  // função para fazer a requisição ao container do back-end
  async function fazerRequisicao() {
    console.log("Fazendo requisição ao back-end...");
    try {
      // fazer uma requisição para a porta do container do back-end
      const response = await fetch("http://back-python-dev/message");
      // receber o retorno da requisição e coletar a resposta em formato json
      const data = await response.json();
      // setar o retorno da requisição como o novo valor da variável resultado
      setResultado(data["message"]);
    } catch (err) {
      // mostrar um alerta caso a requisição não tenha sido realizada por algum motivo
      alert("Requisição não foi realizada");
    }
  }

  return (
    <main
      className={styles.main}
      style={{ backgroundColor: "#0c1f41", color: "#ffffff", padding: 20 }}
    >
      <h1 style={{ marginBottom: 20 }}>
        Front-end do projeto 01 - Requisição ao back-end
      </h1>
      {/* botão que faz a requisição quando clicado */}
      <button
        style={{ padding: 10, margin: 20, fontSize: 24, cursor: "pointer" }}
        onClick={fazerRequisicao}
      >
        Fazer requisição ao back-end
      </button>
      {/* elemento que printa dinamicamente o valor da variável resultado */}
      <h2>Resultado: {resultado}</h2>
    </main>
  );
}
