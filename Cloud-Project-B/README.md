- elaborar Dockerfile
- construir imagem -> `docker build -t projb_frj .`
- correr imagem -> `docker run -d -p 80:80 --name ProjB --hostname WebApp1 projb_frj`

Para remover container:
`docker stop nome-container`
`docker rm nome-container`

project-root/
├── Dockerfile
├── docker-compose.yml
├── docker-compose-logging.yml
├── docker-compose-monitoring.yml
├── howto.txt
├── provision/
│   ├── projectB.conf
│   ├── dump.sql
├── ws/
│   ├── ... (outros ficheiros do ws)
├── app/
│   ├── ... (outros ficheiros do app)
├── logstash/
│   ├── pipeline/
│       ├── logstash.conf
├── nginx/
│   ├── Dockerfile
│   ├── nginx.conf
├── prometheus/
│   ├── prometheus.yml

1. Iniciar o Swarm: `docker stack deploy -c docker-compose.yml mystack`
2. Iniciar a Monitorização: `docker-compose -f docker-compose-monitoring.yml up -d`
3. Iniciar o Logging: `docker-compose -f docker-compose-logging.yml up -d`

Webapp: [http://localhost](http://localhost)
Grafana: [http://localhost:3000](http://localhost:3000) (user: admin, senha: admin)
Prometheus: [http://localhost:9090](http://localhost:9090) -> Recolha de métricas dos serviços
Kibana: [http://localhost:5601](http://localhost:5601)
NGINX: Balanceamento de carga entre as réplicas do serviço webapp
Logstash -> Processar logs e enviar para o Elasticsearch

Docker Swarm: Orquestração de containers, gestão réplicas, balanceamento de carga e alta disponibilidade.
Nginx: Balanceamento de carga, distribuindo o tráfego entre múltiplas instâncias do serviço web.
Prometheus: Recolhe e armazenamento de métricas de performance e saúde dos serviços.
Grafana: Visualização de métricas recolhidas pelo Prometheus.
Elasticsearch: Armazenamento e indexação de logs.
Logstash: Recolha, transformação e envio de logs para o Elasticsearch.
Kibana: Visualização e análise de logs armazenados no Elasticsearch.

################################################################################

Docker Swarm é uma ferramenta de orquestração de containers que permite criar e gerir um cluster de nodes Docker. Ele facilita a implementação de alta disponibilidade, escalabilidade e balanceamento de carga.

Passos Implementados:
Inicialização do Docker Swarm: `docker swarm init`
#Inicia um cluster de Docker Swarm no node atual.

Deploy de um stack com Docker Compose: `docker stack deploy -c docker-compose.yml mystack`
#Implanta o stack definido no docker-compose.yml, criando os serviços definidos no cluster do Swarm.

Os ficheiros docker-compose.yml, docker-compose-logging.yml e docker-compose-monitoring.yml definem os serviços que serão executados, incluindo a configuração das redes, volumes, variáveis de ambiente e parâmetros de implantação.

`docker-compose.yml` -> Este ficheiro define a aplicação principal e seus serviços associados (webapp, base de dados e Nginx).

Serviços:
- webapp:
    - Imagem: webapp_frj:latest
    - Replicas: 3 (três instâncias do serviço web)
    - Healthcheck: Verifica se o serviço está rodando corretamente
    - Rede: webnet
    - Variáveis de ambiente: Configuração da URL da base de dados

- db:
    - Imagem: postgres:13
    - Volumes: Persistência de dados da base de dados
    - Rede: webnet
    - Variáveis de ambiente: Configuração da base de dados
    
- nginx:
    - Imagem: mynginx:latest
    - Portas: Exposição da porta 80
    - Rede: webnet

Rede:
- webnet: Rede interna para comunicação entre os serviços.
    
Volumes:
- db_data: Volume para persistência de dados da base de dados.

`docker-compose-logging.yml` -> Este ficheiro define os serviços necessários para logging centralizado utilizando o ELK Stack (Elasticsearch, Logstash e Kibana).

- elasticsearch:
    - Imagem: docker.elastic.co/elasticsearch/elasticsearch:7.10.1
    - Portas: 9200 (porta padrão do Elasticsearch)
    - Ambiente: Configuração de nó único

- logstash:
    - Imagem: docker.elastic.co/logstash/logstash:7.10.1
    - Volumes: Diretório de configuração do Logstash
    - Configuração: Define a entrada (input) e saída (output) para processamento de logs

- kibana:
    - Imagem: docker.elastic.co/kibana/kibana:7.10.1
    - Portas: 5601 (porta padrão do Kibana)
    
Rede:
- logging: Rede interna para comunicação entre os serviços de logging.
