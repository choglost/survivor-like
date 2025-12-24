class_name WeightedTable

var items: Array[Dictionary] = []

var weight_sum: int = 0

func add_item(item, weight: int):
  items.append({"item": item, "weight": weight})
  weight_sum += weight

func remove_item(item_to_remove):
  for i in range(items.size()):
    if items[i]["item"] == item_to_remove:
      weight_sum -= items[i]["weight"]
      items.remove_at(i)
      return

func pick_item(exclude: Array = []):
  # 可排除权重标准的部分项
  var adjusted_items: Array[Dictionary] = items
  var adjusted_weight_sum: int = weight_sum

  if exclude.size() > 0:
    adjusted_items = []
    adjusted_weight_sum = 0
    for item in items:
      if item["item"] not in exclude:
        adjusted_items.append(item)
        adjusted_weight_sum += item["weight"]

  # TODO：算法性能待优化

  var chosen_weight = randf_range(1, adjusted_weight_sum)
  var iteration_sum = 0
  for item in adjusted_items:
    iteration_sum += item["weight"]
    if iteration_sum >= chosen_weight:
      return item["item"]
