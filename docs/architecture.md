# SurvivorLike 项目架构说明

本文档说明项目的核心架构、事件广播机制和文件目录职责。目标是让后续添加敌人、技能、掉落、升级或 UI 时，有一套稳定的判断标准。

## 项目概览

这是一个 Godot 4.6 的幸存者类游戏原型。游戏入口是主菜单，点击开始后进入主战斗场景。

核心运行链路：

```text
main_menu.tscn
  -> main.tscn
    -> 玩家移动和战斗
    -> 敌人生成
    -> 敌人死亡掉落经验/金币
    -> 拾取经验触发局内升级
    -> 选择升级后强化玩家或技能
    -> 拾取金币写入永久存档
```

主要全局单例在 `project.godot` 的 `[autoload]` 中配置：

```text
GameEvents
MusicPlayer
MetaProgression
```

## 事件广播的作用

事件广播的核心作用是降低系统之间的直接依赖。

以经验拾取为例，如果经验球直接找到 `ExperienceManager` 并调用它的方法，就会产生这样的依赖：

```text
Experience -> ExperienceManager
```

当经验来源增加后，比如任务奖励、宝箱、道具、击杀奖励，每个来源都要知道 `ExperienceManager` 在哪里、方法叫什么、是否已经加载。这会让系统越来越黏。

现在项目使用 `GameEvents` 作为事件总线：

```text
Experience -> GameEvents.experience_gained -> ExperienceManager
```

经验来源只负责广播“玩家获得了经验”，至于谁处理这个事件，由监听者自己决定。

## 当前事件流

`GameEvents` 当前负责三个局内事件：

```gdscript
signal experience_gained(amount: int)
signal coin_gained(amount: int)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
```

对应流程如下：

```text
经验球被拾取
  -> GameEvents.emit_experience_gained(amount)
  -> ExperienceManager.on_experience_gained(amount)
  -> 达到经验上限后发出 level_up
  -> UpgradeManager 弹出升级选择
```

```text
金币被拾取
  -> GameEvents.emit_coin_gained(amount)
  -> MetaProgression.on_currency_collected(amount)
  -> 写入 user://game.save
```

```text
玩家选择局内升级
  -> UpgradeManager.apply_upgrade(upgrade)
  -> GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)
  -> Player / SwordAbilityController / AxeAbilityController 等监听并应用效果
```

## 什么时候使用事件广播

适合使用 `GameEvents` 的场景：

- 一个行为会被多个系统关心，例如金币变化、经验变化、玩家死亡、升级选择。
- 事件来源不应该知道处理者是谁，例如掉落物不应该知道经验管理器的位置。
- 事件是“已经发生的事实”，例如“获得了金币”“获得了经验”“添加了升级”。

不适合使用 `GameEvents` 的场景：

- 同一个节点内部的简单方法调用。
- 父子节点之间非常明确的一对一调用。
- 需要立即返回计算结果的查询，例如获取当前金币、获取永久升级等级。
- 高频逐帧数据，例如玩家每帧位置，除非确实需要全局监听。

简单规则：

```text
广播事实，不广播请求。
状态查询用服务对象，流程通知用事件。
```

例如：

```gdscript
# 合适：通知金币已获得
GameEvents.emit_coin_gained(1)

# 不合适：通过事件询问当前金币
# 应该用 MetaProgression.get_currency()
```

## 场景和系统关系

### 主菜单

路径：

```text
scenes/ui/main_menu/
```

职责：

- 显示开始游戏、商店、设置、退出。
- 点击开始后切换到 `scenes/main/main.tscn`。
- 点击商店后打开元升级菜单。
- 点击设置后打开音量和窗口设置菜单。

### 主战斗场景

路径：

```text
scenes/main/main.tscn
scenes/main/main.gd
```

职责：

- 作为局内所有系统的容器。
- 管理玩家死亡后的结算界面。
- 处理暂停菜单。
- 设置初始音量。

主要子系统：

```text
ArenaTimeManager
EnemyManager
ExperienceManager
UpgradeManager
GameCamera
Player
UI
```

### 时间系统

路径：

```text
scenes/manager/arena_time_manager/
```

职责：

- 记录当前局内时间。
- 定期提升难度。
- 时间结束后显示胜利结算。

它会发出：

```gdscript
arena_difficulty_increased(arena_difficulty: int)
```

`EnemyManager` 监听这个信号来提升刷怪频率和解锁新敌人。

### 敌人生成系统

路径：

```text
scenes/manager/enemy_manager/
```

职责：

- 按计时器刷敌人。
- 根据权重表选择敌人类型。
- 在玩家周围一定半径生成敌人。
- 随难度增加调整刷怪间隔。

当前使用 `WeightedTable` 管理敌人权重。

### 经验系统

路径：

```text
scenes/manager/experience_manager/
```

职责：

- 监听 `GameEvents.experience_gained`。
- 累加当前经验。
- 达到目标经验后升级。
- 发出 `level_up` 信号。

它还会读取 `MetaProgression` 中的永久升级，例如 `experience_gain`，用于降低局内升级所需经验。

### 局内升级系统

路径：

```text
scenes/manager/upgrade_manager/
scenes/ui/upgrade_screen/
resources/upgrades/
```

职责：

- 监听 `ExperienceManager.level_up`。
- 从升级池中抽取若干升级卡。
- 显示升级选择界面。
- 玩家选择后记录当前升级等级。
- 通过 `GameEvents.ability_upgrade_added` 广播升级结果。

升级资源分两类：

```text
AbilityUpgrade
  普通数值升级，例如 sword_damage、player_speed

Ability
  新技能解锁，例如 get_rotate_axe
```

### 永久升级系统

路径：

```text
scripts/autoload/meta_progression/
resources/meta_upgrades/
scenes/ui/meta_menu/
```

职责：

- 维护金币数量。
- 维护永久升级等级。
- 读写 `user://game.save`。
- 提供购买接口。
- 给局内系统提供永久升级等级查询。

推荐调用方式：

```gdscript
MetaProgression.get_currency()
MetaProgression.get_upgrade_level("experience_gain")
MetaProgression.can_purchase(upgrade)
MetaProgression.purchase_upgrade(upgrade)
```

不要让 UI 直接修改 `MetaProgression.save_data`。

## 目录职责

### `assets/`

放原始素材，包括图片、字体、音频等。

```text
assets/audio/
assets/font/
assets/images/
```

规则：

- 只放素材，不放业务脚本。
- Godot 生成的 `.import` 文件保留。

### `component/`

放可复用组件。

当前包括：

```text
component/ability/
component/combat/
component/drop_item/
component/hurt_anim_component/
component/movement/
```

组件应该尽量做到：

- 可挂到多个实体上。
- 少依赖具体场景路径。
- 通过 `owner`、导出变量、组或事件获取必要上下文。

示例：

```text
MovementComponent
HealthComponent
HitboxComponent
HurtboxComponent
DropItemComponent
```

### `entities/`

放游戏世界里的实体。

当前包括：

```text
entities/player/
entities/enemy/
entities/experience/
entities/coin/
```

实体通常由多个组件组合而成，例如敌人包含移动、血量、受击、掉落、音效等组件。

### `resources/`

放数据资源。

当前包括：

```text
resources/upgrades/
resources/meta_upgrades/
resources/theme/
resources/tileset.tres
```

规则：

- 升级、配置、主题、TileSet 等数据放这里。
- 如果一种数据会被多个系统读取，优先做成 `Resource`。

### `scenes/`

放主要场景和 UI。

当前包括：

```text
scenes/main/
scenes/manager/
scenes/ui/
scenes/game_object/
scenes/shaders/
```

建议：

- `scenes/main/` 放局内入口。
- `scenes/manager/` 放系统管理器。
- `scenes/ui/` 放 UI。
- `scenes/game_object/` 放非实体但可复用的场景对象，例如相机、音频播放器。

### `scripts/`

放全局脚本和通用脚本。

当前包括：

```text
scripts/autoload/
scripts/weighted_table/
```

适合放：

- autoload 单例。
- 通用工具类。
- 不属于具体场景的共享逻辑。

### `export/`

放导出产物。

当前有 Web 导出文件。一般业务开发不需要改这里。

## 添加新功能时的推荐位置

### 添加新敌人

推荐步骤：

```text
1. 在 entities/enemy/ 下创建新敌人目录
2. 复用 MovementComponent、HealthComponent、HurtboxComponent、DropItemComponent
3. 在 EnemyManager 中加入对应 PackedScene
4. 加入 enemy_table 权重
5. 如需按时间解锁，在 ArenaTimeManager 难度回调里添加
```

### 添加新局内升级

推荐步骤：

```text
1. 在 resources/upgrades/ 下创建 AbilityUpgrade 资源
2. 在 UpgradeManager 的 upgrade_pool 中加入
3. 在对应系统监听 GameEvents.ability_upgrade_added
4. 根据 upgrade.id 应用效果
```

### 添加新技能

推荐步骤：

```text
1. 在 component/ability/ 下创建技能目录
2. 创建 ability_controller 场景和实际攻击物场景
3. 在 resources/upgrades/ 下创建 Ability 资源
4. 将 ability_controller_scene 指向控制器场景
5. 加入 UpgradeManager 的升级池
```

`Player` 已经监听 `ability_upgrade_added`，当升级资源是 `Ability` 时，会把技能控制器添加到玩家的 `Ability` 节点下。

### 添加新永久升级

推荐步骤：

```text
1. 在 resources/meta_upgrades/ 下创建 MetaUpgrade 资源
2. 加入 meta_menu.tscn 的 upgrades 数组
3. 在需要受影响的系统中读取 MetaProgression.get_upgrade_level(id)
4. 根据等级调整数值
```

例如：

```gdscript
var level = MetaProgression.get_upgrade_level("experience_gain")
```

## 架构约定

### 管理器只管一个系统

例如：

```text
ExperienceManager 只管经验和升级等级
UpgradeManager 只管局内升级选择
EnemyManager 只管刷怪
ArenaTimeManager 只管时间和难度
```

如果一个 manager 开始处理太多事情，就应该拆分。

### UI 不直接改核心状态

UI 可以显示状态、发起操作，但不应该直接修改存档字典或核心系统变量。

推荐：

```gdscript
MetaProgression.purchase_upgrade(upgrade)
```

避免：

```gdscript
MetaProgression.save_data["currency"] -= upgrade.cost
```

### 用资源承载配置

技能、升级、永久升级这类可配置数据应该放在 `.tres` 资源里，而不是硬编码在 UI 或实体脚本中。

### 用组定位跨场景节点

项目中已经使用了这些组：

```text
player
enemy
entities_layer
foreground_layer
```

这适合处理“场景中唯一或一类节点”的查找，例如技能需要找玩家、刷怪需要找实体层。

### 避免过早抽象

目前项目规模还适合保持简单：

- 技能数量少时，可以直接在各自 controller 中处理升级。
- 永久升级数量少时，可以由对应 manager 读取 `MetaProgression.get_upgrade_level(id)`。
- 当技能和永久升级数量明显增加后，再考虑统一效果系统。

## 当前建议的下一步

优先级从高到低：

```text
1. 补更多永久升级，并让它们真正影响局内数值
2. 增加新技能和敌人类型
3. 改善升级池和掉落池配置方式
4. 清理旧注释和编码显示问题
5. 在功能稳定后再考虑目录大搬迁
```

当前不建议做大规模目录重构，因为 Godot 场景和资源引用较多，频繁移动文件会增加 `.tscn`、`.tres` 引用变化风险。
