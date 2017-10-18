+++
date = "2017-05-09T18:19:04-03:00"
draft = false
categories = ["Containers"]
tags = ["docker", "kubernetes", "containers"]
title = "Criando seu cluster Kubernetes na AWS com KOPS"
description = "Apresentamos neste post KOPS, uma ferramenta para auxiliar a criação e deploy de um cluster Kubernetes na AWS."
+++

#### Introdução
Uma ferramenta que facilita a  criação de clusters Kubernetes na AWS é o KOPS. Os passos à seguir mostrarão como instalá-lo e utilizá-lo  para montar seu cluster. Como leitura adicional, recomendo o [Starting Guide](https://kubernetes.io/docs/getting-started-guides/kops/)

&nbsp;
#### Pré requisitos
Verifique se você possuí suas credenciais da AWS no seu arquivo `.aws/credentials`. Você precisará de permissões em EC2 e Route53.

Crie um  domíniou ou subdomínio no Route53 de sua conta AWS. O  KOPS não  irá funcionar se você  não possuir um domínio público gerenciado pelo Route53.

Determine uma faixa de IP para usar em sua nova VPC (ou escolha uma VPC existente). Para clusters temporários ou pessoais, eu costumo usar 10.0.0.0/16.

&nbsp;
#### Instalando KOPS
Para a instalação do KOPS em MAC OS-X, você precisa ter brew instalado antes.

No MAC OS-X faça:
```
brew install kops
```

No Linux, baixe o último release do [KOPS](https://github.com/kubernetes/kops/releases/) e faça:

```
chmod +x kops-linux-amd64
mv kops-linux-amd64 /usr/local/bin/kops
```

Instale o cliente do Kubernetes

No MAC OS-X faça:
```
brew install kubernetes-cli
```

No Linux, faça:
``` 
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
```

&nbsp;
#### Construíndo nosso cluster

Para construir nosso cluster, precisamo de algumas variáveis de ambiente:

**DOMAIN_NAME** aponta para o domínio que criamos no Route53:
```
export DOMAIN_NAME="k8s.example.com"
```

**AWS_PROFILE** aponta para nossas credenciais armazenadas no arquivo `aws/credentials`:
```
export AWS_PROFILE=my_profile
```

**KOPS_STATE_STORE** aponta para o local onde armazenaremos o estado do cluster:
```
export KOPS_STATE_STORE=s3://${AWS_PROFILE}-ops-us-west-1/kops
```

Escolha uma região da AWS para construir seu cluster. Nos exemplos abaixo eu escolhi us-west-1.  Veja quantas AZ a região escolhida possui e defina um CIDR para as subnets que serão  criadas em cada uma dessas AZ. Como us-west-1 possuí duas zonas utilizáveis (us-web-1b e us-west-1c), criarei subnets /22 para elas. Precisamos também ter o par de chaves SSH que permitirá acesso aos hosts do cluster armazenados em nossa máquina. Esse par de chaves pode ter sido criado no próprio painel da AWS, caso em que você precisará extrair a chave pública do arquivo .pem baixado, ou pode ter sido criado por você.

Execute o comando abaixo:
```
kops create cluster --cloud=aws \
  --dns-zone=${DOMAIN_NAME} \
  --master-size=t2.small \
  --master-zones=us-west-1b \
  --master-count=1 \
  --network-cidr=10.0.0.0/22 \
  --node-size=t2.small \
  --node-count=2 \
  --zones=us-west-1b,us-west-1c \
  --name=${DOMAIN_NAME} \
  --ssh-public-key=/path/to/key/${AWS_PROFILE}-kube.pub \
  --admin-access=38.104.140.6/32,52.8.15.187/32 \
  --networking=flannel \
  --kubernetes-version=1.5.4 \
  --image 595879546273/CoreOS-stable-1235.9.0-hvm
```

Este comando preparará  o entorno da AWS para criar os componentes necessários para o Kubernetes funcionar. Dizemos qual é a Cloud utilizada, qual a zona de DNS, os tamanhos das instâncias (temos que começar com t2.small pois o Kubernetes não instalará numa t2.micro por falta de memória), quantos masters e quantos nodes teremos, quais os CIDR de cada uma das nossas AZ, qual o nome do nosso cluster, qual chave SSH utilizaremos (a chave pública será copiada automaticamente para o arquivo de authorized_keys do usuário core), qual nossa versão do  Kubernetes e qual imagem utilizaremos.

&nbsp;
#### Iniciando nosso cluster

Execute o seguinte comando para iniciar nosso cluster:
```
kops update cluster ${DOMAIN_NAME} --yes
```

Teremos que aguardar algum tempo até que o cluster esteja totalmente  pronto  e funcionando.  Diversos componentes serão criados na AWS durante esse processo. Teremos ELB, hosts criados no  Route53, instâncias no EC2 e muito mais. Enquanto aguardamos, gosto de rodar o comando abaixo para verificar o status:
```
while ! kops validate cluster ; do sleep 5 ; done
```

&nbsp;
#### Populando o cluster com serviços standard

Instalamos o dashboard do Kubernetes e ferramentas de monitoração:
```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.2.0.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.5.0.yaml
```

Para testarmos o dashboard, podemos rodar:
```
kubectl proxy
```

Deixe esse comando rodando e aponte seu browser para http://127.0.0.1:8001/ui. Você estará no dashboard do seu cluster Kubernetes.

&nbsp;
#### Populando o cluster com serviços extras

Usaremos o gerenciador de pacotes para Kubernetes chamado [Helm](https://github.com/kubernetes/helm"). Para instalá-lo,

No MAC OS-X faça:
```
brew install kubernetes-helm
```

No Linux, faça:
```
wget https://kubernetes-helm.storage.googleapis.com/helm-v2.2.2-linux-amd64.tar.gz
tar xvfz helm-v2.2.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin
```

Uma vez instalado, prepararemos o cluster para utilizar o Helm:
```
helm init
```

Atualize o caching do Helm com as definições mais atuais:
```
helm repo update
```

Instalamos um pacote no cluster. Como exemplo, vamos montar um Grafana, ferramenta popular de geração de gráficos, bastante usada em monitorações:
```
helm install stable/grafana
```

Siga as instruções geradas pelo comando acima para acessar o seu Grafana novinho em folha. No final, você o acessará pela senha que as instruções deram a você, com usuário admin em http://localhost:443

Para acessarmos o serviço, precisamos perguntar para a API do Kubernetes onde ele está e quais as credenciais de acesso. Utilizaremos também o KOPS para conseguir essas informações:
```
kops get secrets -oplaintext --type=secret kube
```

Para acessar o cluster sem ter que colocar no browser o endereço do nosso domínio, podemos usar assim:

No MAC OS-X:
```
open https://api.${DOMAIN_NAME}/
```

No Linux:
```
xdg-open https://api.${DOMAIN_NAME}/
```

O usuário para acesso ao painel é **admin** e a senha foi a conseguida no passo de `get secrets`.

&nbsp;
#### Destruindo o cluster

Para remover totalmente seu cluster e quaisquer objetos criados para ele na AWS, execute o seguinte comando:
```
kops delete cluster ${DOMAIN_NAME}
```
