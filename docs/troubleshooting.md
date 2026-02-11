# 🛠️ Troubleshooting — Linux LSA-v1

Este documento reúne os problemas mais comuns ao executar o `bootstrap.sh` e como resolvê-los rapidamente.

---

## ❌ Porta do Portainer não abre (9443 ou custom)

### Possíveis causas

* Firewall bloqueando a porta
* Execução em cloud sem regra de entrada liberada

### Verificações

```bash
ss -tulnp | grep 9443
```

```bash
docker ps | grep portainer
```

### Solução (UFW)

```bash
sudo ufw allow 9443/tcp
sudo ufw reload
```

### Solução (Firewalld)

```bash
sudo firewall-cmd --add-port=9443/tcp --permanent
sudo firewall-cmd --reload
```

Em cloud (OCI, AWS, Azure):

* Verifique **Security Lists / Security Groups / NSG**

---

## ❌ Docker instalado, mas só funciona com sudo

### Causa

Usuário não está no grupo `docker`.

### Solução

```bash
sudo usermod -aG docker $USER
```

Depois:

* logout/login **ou**

```bash
newgrp docker
```

---

## ❌ Erro: distro não suportada automaticamente

Mensagem típica:

```
Distro não suportada automaticamente
```

### Causa

Distribuição fora do escopo do script.

### Solução

* Adaptar função de instalação do Docker
* Ou instalar Docker manualmente e rodar apenas a parte do Portainer

---

## ❌ Portainer já existia e não subiu na nova porta

### Causa

Container antigo com mapeamento de portas diferente.

### Solução

O script remove automaticamente o container, mas se necessário:

```bash
docker rm -f portainer
sudo ./bootstrap.sh --portainer-port 9444
```

---

## ❌ Erro ao baixar pacotes Docker

### Possíveis causas

* Proxy corporativo
* DNS incorreto
* Repositório indisponível temporariamente

### Solução rápida

```bash
ping -c 3 download.docker.com
```

Se estiver atrás de proxy:

* Configure proxy no sistema
* Ou exporte variáveis `HTTP_PROXY` / `HTTPS_PROXY`

---

## 🧪 Comandos úteis de diagnóstico

```bash
docker info
docker ps -a
journalctl -u docker --no-pager | tail -n 50
```

---

## 📌 Observação final

Este bootstrap foi pensado para **ambientes limpos**.

Se estiver rodando em um host já configurado:

* Verifique conflitos de porta
* Verifique instalações antigas do Docker

---

Se o problema persistir, abra uma **issue no repositório** com:

* Distro e versão
* Saída do erro
* Logs relevantes
