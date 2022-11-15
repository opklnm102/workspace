# Elasticsearch Cluster Rolling Upgrade
> Elasticsearch cluster를 upgrade하는 방법

<br>

## Prerequirement
- kubectl
- bash
- [watch](https://en.wikipedia.org/wiki/Watch_(Unix))
- [jq](https://stedolan.github.io/jq)

<br>

## Architecture
- 3 Mater eligible nodes
  - elected 1 master node
- 3 Data nodes
- 3 Client nodes

<br>

## kubernetes statefulset
- attach Persistent Volume
- long-term Persistent storage index
- index는 각각 replica shard가 있는 N개의 primary shard로 분할되어 저장
- primary shard와 replica shard는 다른 data node에 저장

## Upgrade
- upgrade-elasticsearch.sh script는 Elasticsearch API와 상호작용하여 cluster configuration을 update하고, cluster status를 monitoring
- Elasticsearch document에 설명된 rolling upgrade procedure와 유사  
- 각 node는 1번에 하나씩 중지되고 upgrade된 버전으로 교체  
- 각 단계마다 cluster가 안정화될 때 까지 기다린다
- process 시작시 disable shard allocation하는 것이 Elasticsearch docs와 다르다  
  - 시작시 `cluster.routing.allocation.enable=none`으로 설정히여 각 data node 삭제시 `UNASSIGNED` shard를 할당하지 않는다  
- shard allocation이 활성화된 경우  
  - `index.unassigned.node_left.delayed_timeout(default 60s)`에 따라 shard가 다른 data node로 이동한다
  - 실제로 shard는 upgrade된 node에서 upgrade되지 않은 node로 이동해야 하는데 Elasticsearch는 이전 버전과 호환되지 않는다 -> disable allocation 이유
  - kubernetes에서는 upgrade를 위해 node를 restart하지 않기 때문에 문제가 발생 
  - new data node가 cluster join하면 attach된 volume은 유지되지만 shard allocation이 disable일 경우 shard initialize가 되지 않고 `UNASSIGNED`로 유지되어 cluster status green이 되지 않는다
- script는 new data node가 cluster에 join시 짧게 shard allocation을 enable하여 initialization step을 허용한 후 다음 data node upgrade 전에 shard allocation을 disable 
  - master, client node는 이런 고려사항이 필요 없다


<br>

## Validation
다른 shell에서 실행

<br>

### Search API
upgrade 하는 동안 search api는 사용가능 해야 한다
```sh
$ watch curl --max-time 1 'http://localhost:9200/snakespeare/_search?q=happy'
```

<br>

### Cluster Health
```sh
$ watch 'curl http://localhost:9200/_cluster/health 2>/dev/null | jq .'
```

<br>

### Shard Allocations
shard allocation을 monitoring하여 data node upgrade 및 recreated시 replica shard가 primary shard로 전환되지만 다른 data node로 relocated되지 않도록 한다
master node re-election 중에 실패
```sh
$ watch curl http://localhost:9200/_cat/shards
```

<br>

### Nodes
node가 cluster에서 떠나고 참여함에 따라 cluster membership을 monitoring
master node re-election 중에 실패
```sh
$ watch curl 'http://localhost:9200/_cat/nodes'
```

```
E0720 12:22:53.871205 37279 portforward.go:331] an error occurred forwarding 9200 -> 9200: error forwarding port 9200 to pod a348720f7d1c5a494a47a084cd94dd4f596f06fbf2180174ac5883f429898a3c, 
uid : exit status 1: 2018/07/20 16:22:53 socat[1239] E connect(5, AF=2 127.0.0.1:9200, 16): Connection refused
```
`upgrade-elasticsearch.sh`에서 생성된 port-forward process가 실패
-> 종료 후 재연결
```sh
$ kill $(ps aux | grep [p]ort-forward | awk '{print $2}')

$ kubectl port-forward svc/elasticsearch 9200
```
