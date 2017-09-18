+++
date = "2017-09-17T10:19:04-03:00"
draft = false
categories = ["Crypto"]
tags = ["crypto", "gpg", "pgp", "email", "hacking"]
title = "Criptografando seus dados com GnuPG (GPG)"
description = "Mostramos neste post como configurar suas chaves de criptografia e criptografar seus e-mails, mantendo sua comunicação segura."
+++

#### Introdução

Embora os sistemas de e-mail atuais e mais populares (GMail, Hotmail, Yahoo) implementem sua própria camada de criptografia quando acessamos nossa conta, seja à partir de uma interface web ou seja à partir de um cliente de e-mail como o Thunderbird, não temos certeza de que o tráfego entre um e outro servidor de e-mail esteja criptografado enquanto nossa mensagem é enviada e trafega pela internet, este ambiente hostil e selvagem, cheio de bandidos, totalmente sem lei, sem o qual não vivemos mais. Em minha não tão humilde opinião, da mesma forma como todo e qualquer site deveria rodar única e exclusivamente debaixo de SSL (https), todo e qualquer e-mail deveria ser criptografado. 

É muito comum vermos senhas enviadas em e-mails totalmente abertas. Recentemente fiz um cadastro em um site qualquer e recebí a senha que eu havia escolhido exposta no e-mail de confirmação do cadastro. Desconfiado, fiz o processo de recuperação de senha e recebí um outro e-mail que, ao invés de conter um token ou uma URL para que eu pudesse resetar minha senha, recebí aa mesma que eu havia criado antes, abertinha para qualquer papagaio-de-pirata (aquele cara que fica olhando por cima do seu ombro enquanto você está trabalhando) ver e anotar. Além de ter recebido a senha aberta, mostrando que ela fica armazenada desta maneira no banco de dados do tal site, o e-mail também estava aberto, sem nenhum tipo de criptografia, facilitando a vida do nosso papagaio-de-pirata.

Ok, a senha em questão foi gerada unicamente para este site, armazenada no ótimo [LastPass](https://lastpass.com), então o risco que eu corria era de ter essa conta desse site comprometida. Mesmo que o site não armazene dados sensíveis demais como um número de cartão de crédito, ainda há lá meu nome, meu CPF, meu e-mail, meu endereço e meu telefone. De posse desses dados, uma pessoa mal-intencionada poderia fazer a festa. Imagine então uma pessoa que usa a mesma senha para todos os cadastros que ela faz! Teríamos aí a senha do Facebook, do Twitter, do Gmail ou Hotmail da pessoa e faríamos uma devassa na vida dela.

Naturalmente, criptografar o e-mail não resolve o problema do site mal desenvolvido que armazena as senhas de seus usuários em plain-text, mas colocaria uma camada de segurança evitando que a senha já tão exposta seja vista por qualquer um que olhe a minha tela.

Vamos então aprender a criptografar nossos e-mails (e outros arquivos que desejarmos) utilizando o sistema chamado [GnuPG](https://gnupg.org), uma variação completa do produto aberto [OpenPGP](http://openpgp.org/), este derivado do PGP de [Phill Zimmermann](http://philzimmermann.com/).

O GPG trabalha com um modelo assimétrico de criptografia de dados. Enquanto nos modelos simétricos a mesma chave utilizada para cifrar um texto é utilizada para decifrá-lo, no modelo assimétrico temos duas partes da chave: uma pública (composite) e uma privada (prime factor). Enquanto o texto é cifrado do lado do remetente com a chave pública do destinatário, ela só pode ser decifrada com a chave privada deste. Além disso, as chaves costumam ser grandes, usando um algorítmo RSA com pelo menos 2048 bits, ou 256 Bytes, o que as torna virtualmente inquebráveis pelos modelos computacionais atuais. 

&nbsp;

#### Pré-requisitos
Para começar você precisa do GPG instalado em seu computador. É um processo simples em qualquer sistema operacional e vou imaginar que você, leitor, tem domínio do seu a ponto de saber procurar um pacote e instalá-lo, seja num Linux com um gerenciador de pacotes, num MacOS com um brew ou em um Windows baixando o instalador do produto, então não cobrirei a sua instalação. 

&nbsp;

#### Operações básicas
Embora seja possível realizar operações mais avançadas com o GPG, inclusive valendo-se de serviços como o [Keybase](https://keybase.io) para construir um driver criptografado para seus arquivos e gerenciar sua cadeia de confiança (web of trust), abordaremos neste artigo as seguintes operações:

* **Criação do par de chaves**
* **Listar chaves**
* **Revogar sua chave**
* **Editar chaves**
* **Compartilhar chaves**
* **Receber chaves**
* **Criptografar uma mensagem**
* **Decriptografar uma mensagem**
* **Assinar uma chave**

Como hoje todos os sistemas operacionais modernos possuem um shell Unix (Linux com seu Bash, Mac OSX também com Bash e Windows com o excelente [Babun](https://babun.github.io) ou mais recentemente, para o Windows 10, com o seu Linux Subsystem, virtualmente um Ubuntu com seu Bash), todos os comandos serão executados assumindo que você, leitor, tem acesso a esse shell. Eu, particularmente, uso o ZSH com uma biblioteca chamada [Oh My ZSH](http://http://ohmyz.sh/) aqui no meu Linux. Assuma também que todos os comandos são executados com um usuário regular, não privilegiado, do sistema, afinal você quer uma chave pessoal, e não a chave do root do seu computador.

&nbsp;

#### Criação do par de chaves

Para criar seu par de chaves, execute o seguinte comando:
```
gpg --gen-key
```

Assim que este comando for executado, ele perguntará que tipo de chave você quer. 

![Figura 1 - Tipos de Chaves](/img/typeofkey.png)

Ficamos com os recomendados RSA com RSA por serem os algorítmos mais fortes que temos. Responda então 1.

A próxima pergunta será o tamanho da chave. Quanto maior a chave, mais tempo levará para alguém fazer um brute force nela, mas mais tempo será necessário para criptografar a mensagem ou o arquivo. Atualmente, como dito antes, uma chave de 2048 bits (256 bytes) oferece segurança suficiente para o nosso dia-à-dia. Se você pode perder alguns mili-segundos a mais criptografando o seu e-mail e queira toda a segurança que o sistema pode oferecer, responda aqui com 4096 (uma chave então de 512 bytes). Se não, responda 2048 e estamos bem.

Em seguida, seremos questionados quanto à expiração da nossa chave. Você pode responder 0 e dizer que a chave nunca vai expirar, e tudo bem se essa for a sua escolha, mas chaves que expiram periodicamente acrescentam uma camada a mais de segurança à sua informação e são muito bem vistas pela comunidade. Podemos aqui definir nossa expiração em dias, semanas, meses ou anos. Vamos, de qualquer maneira, responder 0 aqui e deixar nossa chave sem uma data de expiração. Vai ser solicitada uma confirmação da nossa escolha, à qual respondemos Y.

O próximo dado que temos que informar é o nosso nome. Em teoria, podemos informar qualquer nome aqui, mas se sua intenção é ter uma identidade que realmente pertença a você e que as pessoas saibam que se um arquivo ou mensagem vieram criptografados ou assinados por você, elas podem confiar nessa informação porque o conhecem. Além disso, se você for participar de uma festa de assinatura de chaves, usar um nickname ao invés do seu nome pode fazer suas chaves não serem assinadas (eu passei por isso no FISL de 2010), afinal não existe M3gaHax0rEL33tLuz3rSec no seu RG, certo? Informaremos então nosso nome real, como consta em um documento válido de identidade.

Seremos questionados sobre o e-mail que será utilizado com a nossa chave. Esse é o nosso ID e será a forma mais simples de acessarmos a chave. Digite seu e-mail e não se preocupe se você utilizar vários. Você pode depois adicionar novos e-mails à esta chave (ou criar novas chaves para cada um dos e-mails que você possuir). A minha chave atual tem vários e-mails meus. 

Quer colocar um comentário qualquer na sua chave? Aproveite o próximo campo para isso.

O sistema vai solicitar a confirmação dos dados antes de gerar a sua chave. Essa é a sua última oportunidade de mudar algo, sob pena de ter que começar tudo de novo. Se estiver satisfeito, escolha a opção O.

Se receber uma mensagem dizendo que gpg-agent não está disponível para sua sessão, ignore-a. Então, escolha a senha da sua chave. Essa senha criptografará sua chave privada e será solicitada todas as vezes que você usar essa chave. Escolha sabiamente. Se sua chave privada for comprometida, a pessoa poderá passar-se por você e ler suas informações criptografadas. Lembre-se sempre de [XKCD](https://xkcd.com/936/). Já encontrei diversas contas por aí cuja senha era alguma variante de Tr0ub4dor&3.

Nesse momento sua chave será gerada, mas você seguramente receberá uma mensagem assim:

<i>We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

Not enough random bytes available.  Please do some other work to give
the OS a chance to collect more entropy! (Need 283 more bytes).</i>

Como dito anteriormente, a chave é calculada e gerada baseando-se em números primos. Para que o sistema gere números primos grandes, dados randômicos precisam ser coletados. Isso é feito à partir da execução de processos mais pesados no seu SO, como a leitura de um disco ou o mouse andando aleatoriamente para lá e para cá. Eu gosto de gerar esses dados assim:

```
find / -type f
```

Esse comando listará todos os arquivos existentes no seu disco e gerará dados suficientes para a criação da sua chave. Ou, se você tiver um gato, deixe-o passear pelo seu teclado. Gatos são ótimos para gerar eventos aleatórios, [computação quântica](https://pt.wikipedia.org/wiki/Gato_de_Schr%C3%B6dinger) e [anti-gravidade](https://pt.wikipedia.org/wiki/Paradoxo_do_gato_e_p%C3%A3o_com_manteiga), mas tenha certeza de usar manteiga e não margarina para isso.

Relaxe. Isso leva algum tempo. **CUIDADO!!!** Essa entropia é gerada por hardware. Se você estiver montando sua chave numa máquina virtual (usando VirtualBox, por exemplo), esse processo poderá levar um tempo infinito, porque o GPG não saberá ler o hardware do host. Então, faça algo assim dentro da sua VM:

```
for X in $(seq 1 100); do find / -type f -exec ls -l {} \; ; done
```

Assim que o prompt voltar para você sua chave estará gerada. Mas, onde ela está? 

Você vai notar que um diretório chamado .gnupg foi gerado no seu $HOME. Dentro dele você terá os bancos de dados que o GPG usa para armazenar suas chaves:

- pubring.gpg
- secring.gpg
- trustdb.gpg

Esses arquivos são os que compõem o nosso keyring (chaveiro). Nesses arquivos são armazenados respectivamente nossas chaves públicas (e as de outras pessoas), nossas chaves privadas e nossa web of trust, ou as chaves que escolhemos explicitamente confiar. Faça um backup desses arquivos regularmente.

Nosso sistema está pronto para operar com GPG. Vamos agora ler nossa chave.

&nbsp;

#### Listando as chaves

O seguinte comando lista nossas chaves de qualquer tipo:

```
gpg --list-keys
```

Se quisermos listar somente as chaves privadas, usamos:

```
gpg --list-secret-keys
```

Neste momento, os dois comandos devem gerar a mesma saída, já que somente temos nossa chave no banco de dados do GPG.

Há uma informação importante nesses dados. Se notarmos a linha que diz *pub* ou *sec*, dependendo do comando, veremos um dado mais ou menos assim:

```
pub   2048R/7407765A 2017-09-17
```

Isso nos informa que nossa chave é uma RSA de 2048 bits, criada em 17 de setembro de 2017 e seu ID é 7407765A.

&nbsp;

#### Revogar sua chave

A comunidade envolvida com GPG e OpenPGP leva muito à sério o cuidado e a validação das informações existentes em uma chave. Possuir uma chave é uma responsabilidade grande e mantê-la atualizada é obrigação constante do seu dono. 

Uma das coisas mais importantes é dizer que sua chave não é mais válida. Ela pode ser automaticamente invalidada se a criamos com uma data de expiração, mas caso seja comprometida, precisamos revogá-la. Isso é feito criando e importanto um certificado de revogação.

Para criar seu certificado de revogação, execute o seguinte comando:

```
gpg --gen-revoke -o email.rev <ID>
```

Nos será perguntado o motivo da criação do certificado e comentários adicionais, e uma confirmação será pedida. Também será pedida a senha da chave privada. Então o arquivo email.rev será gerado em seu disco. É recomendado que esse arquivo seja salvo em algum outro lugar e até mesmo impresso. Como ele é pequeno, pode ser facilmente digitado. 

O certificado de revogação é gerado à partir da sua chave privada, portanto se você não mais a possuir, não poderá revogá-la e ficará com sua chave válida até sua expiração ou para sempre.

**ATENÇÃO!** Importar o certificado de revogação é irreversível! Uma vez revogada, uma chave não pode voltar à seu estado válido, a não ser que tenhamos um backup dos bancos de dados do GPG. As ações abaixo revogarão a chave gerada anteriormente. Antes de prosseguir, certifique-se de que você tem seu backup do diretório .gnupg.

Gerar o certificado de revogação não significa revogar imediatamente a chave. Para fazer isso você precisa importá-lo, assim:

```
gpg --import email.rev
```

A saída desse comando é similar à:

```
vagrant@vagrant-ubuntu-trusty-64:~$ gpg --import chave.rev 
gpg: key 7407765A: "My Real Name <myreal@email.com>" revocation certificate imported
gpg: Total number processed: 1
gpg:    new key revocations: 1
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
```

Se listarmos a chave, veremos que há agora uma informação de revogação nela:

```
vagrant@vagrant-ubuntu-trusty-64:~$ gpg --list-keys
/home/vagrant/.gnupg/pubring.gpg
--------------------------------
pub   2048R/7407765A 2017-09-17 [revoked: 2017-09-17]
uid                  My Real Name <myreal@email.com>
```

O próximo passo é exportar nossa chave pública e enviá-la para nossa teia de confiança e/ou para um keyserver. Teremos maiores detalhes sobre isso na sessão **Compartilhando nossa chave**.

Manter seguro o certificado de revogação é tão importante quanto manter nossa chave pública segura, pois ele é a única maneira de dizermos ao mundo que nossa chave não é mais válida e que portanto as pessoas não devem mais confiar nela.

&nbsp;

#### Editando nossa chave

O GPG tem uma interface de linha de comando (CLI) que nos permite executar a edição de vários aspectos de nossa chave. Para acessá-lo, faça:

```
gpg --edit-key <ID>
```

Um prompt nos será mostrado:

```
gpg>
```

Podemos utilizar o comando *help* para listar todos os comandos disponíveis.

Uma coisa que podemos fazer neste modo é adicionar uma ID à nossa chave já existente. Imaginemos que temos, além do e-mail myreal@email.com, nosso notsoreal@email.com, e queremos adicioná-lo à mesma chave. No prompt de edição de nossa chave utilizamos o comando *adduid*:

```
gpg> adduid
```

A sessão se parecerá com algo como:

```
gpg> adduid
Real name: My Not So Real Name
Email address: notsoreal@email.com
Comment: 
You selected this USER-ID:
    "My Not So Real Name <notsoreal@email.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o

You need a passphrase to unlock the secret key for
user: "My Real Name <myreal@email.com>"
2048-bit RSA key, ID 7407765A, created 2017-09-17

pub  2048R/7407765A  created: 2017-09-17  usage: SC  
                     trust: unknown       validity: valid

sub  2048R/D3E70A26  created: 2017-09-17  revoked: 2017-09-17  usage: E   
(1)  My Real Name <myreal@mail.com>
(2). My Not So Real Name <notsoreal@email.com>
```

Agora, se alguém enviar um e-mail para notsoreal@email.com, ele poderá ser criptografado com a mesma chave de myreal@email.com.

Diversas outras opções existem na edição das chaves. Se você tiver um backup do banco de dados do GPG, pode testar todas.

Algumas outras opções como a assinatura e a confiança de uma chave pública de outra pessoa serão abordadas adiante neste artigo.

&nbsp;

#### Compartilhando nossa chave

Como o objetivo aqui é fazer parte de uma comunidade onde todos trocam as mensagens de forma segura e criptografada, é interessante compartilharmos nossa chave pública. Podemos fazer isso de duas maneiras:

* ___Exportando nossa chave pública para um arquivo e enviando-a a alguém___

Para exportar nossa chave para um arquivo, podemos utilizar o seguinte comando:

```
gpg -a -o pubkey.txt --export <ID>
```

O *<ID>* neste caso pode ser nosso e-mail ou o valor hexadecimal que pegamos em nosso list-keys. Esse comando vai gerar (*--export*) um arquivo (*-o*) chamado pubkey.txt que é a descarga em ASCII (*-a*) da nossa chave (*ID*). Seu conteudo é extenso e parece-se com isso:

```
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQGiBEK5Z9cRBACYslU9tYfH76zbY7wfi5DQV/CoExvtYZ0sr8tDK/qRqfAZn6F7
V/xNKWU8hXVauPE1AAR+6LvW3OZPzwQwtb+lwaowWp9sX/o5arglwr7Ey3r4H2sx
[...]
-----END PGP PUBLIC KEY BLOCK-----
```

Envie esse arquivo aos seus amigos. Se eles não souberem o que fazer com isso, envie o link deste artigo para eles.

* ___Enviando nossa chave pública para um servidor de chaves___

Existem milhares de servidores espalhados pelo mundo que armazenam chaves públicas e que espalham essas chaves para os outros servidores, formando uma teia redundante onde não importa em qual servidor enviamos nossa chave, ela existirá em todos os outros em poucos segundos.

Para mandar nossa chave para um servidor público, utilizamos o seguinte comando:

```
gpg --keyserver hkp://pool.sks-keyservers.net --send-key <ID>
```

pool.sks-keyservers.net é um serviço que contém diversos servidores de chaves e encarrega-se de enviar a sua chave para um deles e, depois, distribuí-la para o mundo. Também podemos usar o pgp.mit.edu, bastante estável e seguro.

Esse comando enviará sua chave pública para esse pool de servidores e ela estará publicada. Nunca mais essa chave será excluída e qualquer pessoa poderá ter acesso a ela. 

&nbsp;

#### Recebendo chaves públicas

Se as pessoas com as quais vamos compartilhar informações de maneira criptografada também enviaram suas chaves para um servidor, é possível conseguir essas chaves à partir dele. Você só precisa ter o ID da chave. 

Para conseguí-lo, você pode fazer uma busca em alguma ferramenta disponível. Um bom lugar para se procurar é o serviço de chaves do MIT, que fica em [](http://pgp.mit.edu/). Se você procurar simplesmente por mrbits, vai receber uma listagem de todas as chaves que eu um dia subi para algum servidor de chaves. Várias delas, infelizmente, foram perdidas e não me foi possível revogá-las, mas minha primeira chave data de 30/07/1997. Sou, então, um feliz usuário de criptografia por já 20 anos. 

Minha chave válida é a de ID 2B3CA5AB, datada de 19/01/2010. Essa chave nunca foi comprometida e seu certificado de revogação existe e está muito bem guardado. 

Para importá-la para o seu keyring, execute o seguinte comando:

```
gpg --keyserver hkp://pool.sks-keyservers.net --recv <ID>
```

O *<ID>* deve ser o valor hexadecimal da chave. No caso da minha, esse valor é 6EC818FC2B3CA5AB e pode ser conseguido na ferramenta de busca de chaves do MIT.

A saida do comando será mais ou menos assim:

```
gpg: requesting key 2B3CA5AB from hkp server pool.sks-keyservers.net
gpg: key 2B3CA5AB: public key "Diogo Carlos Fernandes (MrBiTs) <mrbits.dcf@gmail.com>" imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)

```

Importamos com isso nossa primeira chave. Se agora executamos um --list-keys, veremos a nossa chave privada e a chave que importamos.

&nbsp;

#### Assinando uma mensagem

Quando as relações de confiança são estabelecidas, podemos enviar um e-mail a alguém que possua nossa chave pública que não precisa ser necessariamente criptografado, mas que pode ser digitalmente assinado. Podemos fazer o mesmo com um arquivo que geramos, de forma que o destinatário possa validar que os dados vêm de uma fonte que ele confia.

Uma assinatura digital certifica e valida o timestamp de um arquivo ou mensagem. Se após sua assinatura ele for modificado, a verificação desta falhará. 

Vamos criar um arquivo contendo alguma informação qualquer e chamá-lo de topsecret.txt.

```
cat >topsecret.txt<__EOF__
Este arquivo é confidencial e contém informações
que somente podem ser lidas por pessoal autorizado.

Aqui vem uma senha
Aqui vem um número de cartão de crédito, sua data
de expiração, seu CVV, nome e tudo o mais que os
bandidos adoram ter em seu poder.

__EOF__
```

Se vamos trabalhar com mensagens de e-mail, eu prefiro assiná-las em clear sign. Se por outro lado vamos assinar um arquivo (um documento, uma imagem) eu trabalho com assinaturas detached. 

* ___Assinando mensagens em clear sign___

Execute o seguinte comando:

```
gpg -o topsecret.sig --local-user <EMAIL> --clearsign topsecret.txt
```

O resultado do arquivo topsecret.sig será algo assim:

```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Este arquivo é confidencial e contém informações
que somente podem ser lidas por pessoal autorizado.

Aqui vem uma senha
Aqui vem um número de cartão de crédito, sua data
de expiração, seu CVV, nome e tudo o mais que os
bandidos adoram ter em seu poder.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCAAGBQJZvwmlAAoJEG7IGPwrPKWrieUH/ihHnkmCXA4epbw+h8AjU0wk
6s4Cf7STYnqCtuzR35RSWxe9Jh2HqPfWaJbj3A+CaHMDIVsAwpegiBvBEhPSZgIC
tS0nYPnLUyblAOhalm5vRVqu18Wtq1cNPa+6yy4KIZxeP8xp/Ooc1Nnxe6T2tjnt
Y8/w+mzam3gdxFQIbwq+G6JMLB4J0czIv6Hji7G1S6YOofEC9xT2Q9Qe4TvnZpRT
udvK7V3Y9O3S2MBVYsi2NDNeBnLfapuH8f9nYoK190xz+vPXNjbAITeIAHZ+iNLw
pNrayqVdcMzRbYB5aq6Y7zV5Me0HmvAJfLQkx7J+2OeWtmnDcDPwDHknUjtr3JE=
=I6fH
-----END PGP SIGNATURE-----
```

Vemos que a mensagem original foi mantida e algumas referências a assinatura digital foram inseridas.

Para verificar a mensagem, executamos:

```
gpg --verify topsecret.sig
```

Se o resultado contiver *Good signature*, então nossa mensagem veio de uma fonte confiável

* ___Assinando arquivos com assinaturas detached___

Se temos um arquivo preparado por nós, como por exemplo um documento que queremos enviar mas que não pode ter seu conteúdo modificado com as informações do GPG, podemos assiná-lo com uma assinatura detached. Para isso, executamos

```
gpg -o topsecret.sig --local-user <EMAIL> --detach-si topsecret.txt
```

Um arquivo chamado topsecret.sig será criado e deverá ser enviado em conjunto com nosso documento. Para saber se o arquivo é válido e veio de uma fonte confiável, executamos o mesmo --verify, mas agora precisamos informar também o arquivo, além da assinatura:

```
gpg --verify topsecret.sig topsecret.txt
```

Novamente a mensagem de *Good signature* deve aparecer. Se, ao contrário, obtivermos uma *Bad signature*, então ou a chave com a qual o arquivo foi assinado não é a que temos em nosso keyring ou o arquivo foi modificado de alguma maneira.

&nbsp;

#### Criptografando uma mensagem

Agora, nossa mensagem contém dados sensíveis e que queremos proteger, então devemos criptografá-la. Uma mensagem pode ser criptografada para um ou mais usuários e até mesmo somente para você. Tudo o que vc precisa é ter a chave pública dos usuários importada no seu keyring e saber quais são seus ID que são os e-mails desses usuários. 

Para criptografar uma mensagem basta fazer:

```
gpg -e -a topsecret.txt
```

O comando pedirá os destinatários da mensagem, um por vez. Após colocar todos, termine com um ENTER. Um arquivo topsecret.txt.asc será gerado, com um conteúdo mais ou menos assim:

```
-----BEGIN PGP MESSAGE-----
Version: GnuPG v1

hQEMA0TtRpX+KwRXAQgAzxv5U0pCH4QcSR5pb4uTYNK+QAe77UQNlXG55onzh8Qe
zRwJWtIWS0diU9jev/si7hMUlh8XeCWB7PBHi3olloD/WjQt9Fz6nFbB7NMuhN9/
4tdeNsBbhsJcjvwBtyv3K5bG1y2tvjGRpg1rLOYkWILmR4qJznGNFB3Lxx+0y2g5
VrPR1mk1YPhOV7PD/vH230BKyt/u+geNYCbGHU3V1GkDnbSAWXag1ig82cbA68f9
Nt2rBwnXin9ir8ExvPm+NAuxSYrrA6yHJVQ+7hbvzjaEQTmeGzHmbTvpfPpnW//P
26FK+B6gSGSmTwmk6Y5sXXbFo1XOVC/zNUZVWt4z5tLARAFXf8cXqcTh1MzAvGsm
Jk0JJNY81ViWeeXUZaDtcGjMnOpB1umq5ZcTeAyk3XXTsk9KqgY38SXxkVTwIxk0
+7O5xtKlNiG/RuowZK6k2m/4k6hxiL4aYrAs87tPQx3zciuhgBYGbqwX22kK6SbA
vH9oGRgTo1130J25KKwSRK/TmbrlqT+BaEgAd/LN5F9UgRqv92iIHLOGKPJfqxcP
AT7DnbzmrTIdIFguasCpDCnvxWkLYPFfKxqCCndUVLtSQ6vcuBwjkMRVc+iel167
IEeoSIYwP2OwKExfwv0kn2txLDXfymHeTbpQB4reBXO0vQi7SeT/Rw01vAgYgIhq
as1/7h95
=5xTK
-----END PGP MESSAGE-----
```

Envie este arquivo aos seus destinatários. Eles, de posse de sua (deles) chave privada, serão capazes de ler a mensagem.

É possível também criptografar a mensagem *inline*. Execute o comando gpg somente com a opção *-e*. Os destinatários serão pedidos e depois você poderá digitar o texto. CTRL+D mostrará a mensagem criptografada. Copie-a e cole-a no corpo de um e-mail. Não se esqueça das linhas de BEGIN e END.

&nbsp;

#### Decriptografar uma mensagem

E então recebemos uma mensagem criptografada. O e-mail que recebemos de nossa fonte confiável contém o arquivo topsecret.txt.asc. 

Basta colocar esse arquivo em seu disco e executar:

```
gpg -d topsecret.txt.asc
```

O GPG vai pedir a senha da nossa chave privada e, após digitá-la, leremos a mensagem.

Também podemos decriptografar *inline* utilizando a opção *-d* do comando gpg sem passar o arquivo e simplesmente colar o seu conteúdo previamente copiado. Não se esqueça de copiar também as linhas de BEGIN e END. Após digitar a senha, CTRL+D mostrará a mensagem aberta. 

&nbsp;

#### Assinar uma chave



&nbsp;

#### Web of Trust

Falar sobre fingerprint, conceito de web of trust, como receber uma chave, como validar um usuário

&nbsp;

#### Exercícios de operação com chaves

Neste exercício enviaremos nossa chave pública para um servidor, importaremos a minha chave pública de um servidor de chaves, validaremos seu fingerprint, assinaremos e enviaremos novamente a este servidor. 

**a)** ___Enviando a chave para um servidor___

Para enviar sua chave para um servidor, execute o seguinte comando:

```
gpg --keyserver hkp://pool.sks-keyservers.net --send-key <ID>
```


**b)** ___Importando uma chave___

O ID da minha chave é 6EC818FC2B3CA5AB. Para importá-la para o seu keyring, execute o seguinte comando:

```
gpg --keyserver hkp://pool.sks-keyservers.net --recv 6EC818FC2B3CA5AB
```

Após a execução do comando, valide a importação da chave com 

```
gpg --list-keys
```


**c)** ___Validando o fingerprint___

Para extrair o fingerprint da minha chave, use o seguinte comando:

```
gpg --fingerprint 6EC818FC2B3CA5AB
```

O fingerprint da minha chave é 

```
29F1 6B05 FCCA C89B 4062 12B4 6EC8 18FC 2B3C A5AB
```

Valide-o com a chave que você recebeu do servidor no passo *a*.

**d)** ___Assinando a chave___

Uma vez que a chave tenha sido validada pelo seu fingerprint, podemos assiná-la. Para isso, execute o seguinte comando:

```
gpg --sign-key 6EC818FC2B3CA5AB
```

Novamente há a possibilidade de validarmos o fingerprint da chave. Sua senha será pedida, já que a minha chave pública vai ser assinada com sua chave privada. Uma confirmação deve ser feita. 

**e)** ___Enviando a chave ao servidor___

Para enviar a minha chave pública, agora assinada por você, execute:

```
gpg --keyserver hkp://pool.sks-keyservers.net --send-key 6EC818FC2B3CA5AB
```

Após o sucesso dessa operação o exercício está concluído.

&nbsp;

#### Considerações finais

Segurança de dados é responsabilidade individual de algo coletivo. De nada adianta você receber uma informação em um e-mail criptografado e reenviá-la em texto aberto. 

Segurança dá trabalho. É muito mais fácil enviar um e-mail sem criptografia ou ter a mesma senha para o suas contas de e-mail, Facebook, Twitter e sua conta bancária, mas o risco de ter suas informações expostas e sua conta limpa é grande. Difundir segurança é um trabalho ingrato, porque você sempre vai ouvir aquele diretor falar que "nosso cliente não vai perder tempo instalando esse software e tendo que clicar em mais de um botão para abrir o e-mail". E ele não está errado. A grande maioria das pessoas realmente não vai querer perder tempo com isso. Nada podemos fazer. O que podemos fazer é manter nossa teia de confiança. O que eu faço quando tenho que passar informação sensível é passá-la verbalmente ou pedir à pessoa que vai recebê-la que saiba que está recendo uma informação sensível aberta e que ela é responsável pela segurança dessa informação daí em diante.

Se o leitor tiver dúvidas, críticas ou quiser sugerir correções e melhorias para este artigo, por favor envie-me um [e-mail](mailto:mrbits@mrbits.com.br), criptografado, naturalmente.

&nbsp;

#### Referências

[GNU Privacy Handbook](https://www.gnupg.org/gph/en/manual.html)

[Keybase.IO](https://keybase.io)
