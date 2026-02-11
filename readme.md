# 🐧 Linux Bootstrap — Docker + Portainer

![Linux](https://img.shields.io/badge/Linux-supported-brightgreen?logo=linux)
![Docker](https://img.shields.io/badge/Docker-required-blue?logo=docker)
![Shell](https://img.shields.io/badge/Shell-Bash-black?logo=gnu-bash)

Automação **one-shot** para preparar rapidamente um host Linux com **Docker Engine**, **Docker Compose (plugin oficial)** e **Portainer** como **primeiro container**.

Pensado para **labs DevOps**, **VMs cloud**, **homelab** e **servidores recém-provisionados**.

---

## ✨ O que este script faz

* Detecta a distribuição Linux automaticamente
* Instala Docker Engine (repo oficial)
* Instala Docker Compose (plugin v2)
* Habilita e inicia o serviço Docker
* Sobe o **Portainer CE** com volume persistente
* Permite customizar a porta HTTPS do Portainer

---

## 📦 Distribuições suportadas

* Ubuntu / Debian
* RHEL / CentOS / Rocky / Alma

---

## 🚀 Quickstart

```bash
chmod +x bootstrap.sh
sudo ./bootstrap.sh
```

Após a execução:

👉 Acesse: `https://SEU_IP:9443`

No primeiro acesso, crie o usuário **admin** do Portainer.

---

## 🔧 Customização

### Porta HTTPS do Portainer

Por padrão, o Portainer expõe a interface web na porta **9443**.

Para alterar:

```bash
sudo ./bootstrap.sh --portainer-port 9444
```

Acesso:

```
https://SEU_IP:9444
```

---

## 📁 Estrutura do projeto

```
linux-bootstrap/
├── LSA-v1-DCP.sh        # Script principal (automação)
├── README.md           # Documentação
├── LICENSE
├── .gitignore
└── docs/
    └── troubleshooting.md
```

---

## 🔐 Boas práticas recomendadas

* 🔒 Restringir a porta do Portainer no firewall (UFW / Firewalld)
* 🔑 Usar senha forte no usuário admin
* 🌐 Expor o Portainer apenas em rede privada ou via VPN
* 🧱 Criar stacks via Docker Compose dentro do Portainer

---

## 🧪 Validações realizadas pelo script

* `docker --version`
* `docker compose version`
* Containers em execução

---

## 🧠 Casos de uso

* Provisionamento rápido de VMs cloud (OCI, AWS, Azure)
* Ambientes de estudo DevOps / SRE
* Homelab
* Base para CI/CD, Observability e stacks Docker

---

## 📌 Próximos passos (roadmap)

* [ ] Flags adicionais (`--no-portainer`, `--docker-only`)
* [ ] Instalação opcional de Watchtower
* [ ] Configuração automática de firewall
* [ ] Suporte a proxy
* [ ] Shellcheck + CI

---

## 📜 Licença

MIT License.

---

💡 **Objetivo do projeto:** reduzir o tempo de setup de um host Linux para poucos minutos, com Docker pronto e gerenciável via Portainer.
