# DeepSeek-V4 Router Computational Workflow

Source: [DeepSeek-V4 technical report](https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro/blob/main/DeepSeek_V4.pdf).

The DeepSeek-V3 router works as follows:

```python
def dsv3_router(
    x: Tensor[float, (B, H)],
    Wr: Tensor[float, (H, E)],
    expert_bias: Tensor[float, (E)],
    topk: int,
    group_topk: int,
    routing_scaling_factor: float,
) -> tuple[Tensor[int, (B, k)], Tensor[int, (B, k)]]:
    routing_logits = x @ Wr
    affinity_score = sigmoid(routing_logits)
    biased_score = affinity_score + expert_bias
    topk_indices = grouped_topk(biased_score, topk, group_topk)
    topk_weights = affinity_score.gather(dim=-1, index=topk_indices)
    topk_weights = topk_weights / topk_weights.sum(dim=-1, keepdim=True)
    topk_weights = topk_weights * routing_scaling_factor
    return topk_indices, topk_weights
```

Two major changes are made in the DeepSeek-V4 router:
1. The activation change from `sigmoid` to `sqrt(softplus)`.
2. The node-limiting routing strategy is removed. (`grouped_topk` to conventional `topk`)

The DeepSeek-V4 router works as follows:

```python
def dsv4_router(
    x: Tensor[float, (B, H)],
    Wr: Tensor[float, (H, E)],
    topk: int,
    routing_scaling_factor: float,
) -> tuple[Tensor[int, (B, k)], Tensor[float, (B, k)]]:
    routing_logits = x @ Wr
    affinity_score = sqrt(softplus(routing_logits))
    topk_indices = topk(affinity_score, topk)
    topk_weights = affinity_score.gather(dim=-1, index=topk_indices)
    topk_weights = topk_weights / topk_weights.sum(dim=-1, keepdim=True)
    topk_weights = topk_weights * routing_scaling_factor
    return topk_indices, topk_weights
```

## Hash Routing

In DeepSeek-V3, the first 3 layers are dense FFNs. In DeepSeek-V4, it is replaced by a hash-routed MoE layer. The selected experts are directly mapped from the input token ids.

```python
def hash_router(
    x: Tensor[int, (B, H)],
    token_ids: Tensor[int, (B)],
    Wr: Tensor[int, (H, E)],
    tid2eid: Tensor[int, (V, k)],
    routing_scaling_factor: float,
) -> tuple[Tensor[int, (B, k)], Tensor[float, (B, k)]]:
    routing_logits = token_ids @ tid2eid
    affinity_score = sqrt(softplus(routing_logits))
    topk_indices = tid2eid[token_ids]
    topk_weights = affinity_score.gather(dim=-1, index=topk_indices)
    topk_weights = topk_weights / topk_weights.sum(dim=-1, keepdim=True)
    topk_weights = topk_weights * routing_scaling_factor
    return topk_indices, topk_weights
```
