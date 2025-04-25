一种基于MATLAB R2022b的安科战斗脚本全自动实现

适用于两个阵营的大规模战斗推演和小队作战推演

脚本可自定义阵营名称，最大可执行回合，单位与加成信息

战斗流程会在MATLAB的控制台中显示，可以通过选中复制后手动存储

战斗完成后脚本会自动输出双方的损失报告为表格文件: FA_unit_lost_report.xlsx，FB_unit_lost_report.xlsx

脚本文件说明

battle.m 歼灭战模式，支援单位无法被攻击

battle1.m 歼灭战模式，支援单位可以被支援单位选中攻击

battle1_allunitycanattack.m 歼灭战模式，支援单位可以被选中攻击

battle2.m 据点争夺模式，阵营A默认为战役防守方，阵营B默认为战役进攻方，支援单位可以被选中攻击，目前未考虑据点重新翻转为中立的情况


脚本文件运行的所需资料文件说明


Information.xlsx

包含双方战斗胜利条件，场景信息
当前格式为 阵营 胜利条件 最大回合数 
交战最大回合上限建议设置为10，最大建议不超过20


bfset.xlsx

战场的据点设置，在据点争夺模式使用，所属权由0 1 2设置，其中，0 中立，1 A阵营控制，2 B阵营控制 
格式为 据点名称 控制权所属


Ap.xlsx

A阵营加成文件-用于为在战斗轮的判定中提供点数加成(由于未测试加成总和为负数的效果，应当避免加成总和为负数的情况出现)
格式为 加成名 加成点数


Aunit.xlsx

A阵营的一线战斗单位信息-对应前排单位，直接投入战场交战的战斗部队单位
格式为 单位名 数量 战斗点数(生命) 总点数


AunitS.xlsx

A阵营的支援单位信息-对应后排单位，炮兵等可直接进行攻击的支援战斗单位
格式为 单位名 数量 战斗点数(生命) 总点数


Bp.xlsx

B阵营加成文件-用于为在战斗轮的判定中提供点数加成(由于未测试加成总和为负数的效果，应当避免加成总和为负数的情况出现)
格式为 加成名 加成点数


Bunit.xlsx

B阵营的一线战斗单位信息-对应前排单位，直接投入战场交战的战斗部队单位
格式为 单位名 数量 战斗点数(生命) 总点数


BunitS.xlsx

B阵营的支援单位信息-对应后排单位，炮兵等可直接进行攻击的支援战斗单位
格式为 单位名 数量 战斗点数(生命) 总点数


代码构建目前仅考虑功能实现，未进行函数封装与功能封装，需要在MATLAB上运行脚本，建议使用MATLAB R2022b进行运行，以避免不必要的乱码出现

A Full Automated Implementation of Combat Script Based on MATLAB R2022b

Suitable for large-scale battle simulations and squad-level combat drills between two factions.

The script allows customization of faction names, maximum execution rounds, unit data, and bonus information.

The combat process will be displayed in the MATLAB command window. You can manually save the logs by selecting and copying the text.

After the battle concludes, the script will automatically generate loss reports for both factions as Excel files:

FA_unit_lost_report.xlsx (Faction A losses)

FB_unit_lost_report.xlsx (Faction B losses).


Script File Descriptions


battle.m: Annihilation mode, support units cannot be attacked.


battle1.m: Annihilation mode, support units can be targeted by other support units.


battle1_allunitycanattack.m: Annihilation mode, support units can be fully targeted for attacks.


battle2.m: Stronghold conquest mode. Faction A is the default defender, Faction B is the default attacker. Support units can be targeted. Note: The script currently does not account for strongholds reverting to neutral status.



Required Data Files for Script Execution

Information.xlsx

Contains victory conditions and scenario settings for both factions.
Format:

Faction | Victory Condition | Maximum Rounds

Recommended maximum round limit: 10 (do not exceed 20).


bfset.xlsx

Stronghold settings for the battlefield (used in stronghold conquest mode).
Control ownership is defined as:

0: Neutral, 1: Controlled by Faction A, 2: Controlled by Faction B.
Format:

Stronghold Name | Control Ownership


Ap.xlsx

Faction A bonus file—provides point bonuses during combat round calculations.
Note: Avoid negative total bonuses (untested).
Format:

Bonus Name | Bonus Points


Aunit.xlsx

Faction A frontline unit data—direct combat units deployed on the battlefield (frontline).
Format:

Unit Name | Quantity | Combat Points (HP) | Total Points


AunitS.xlsx

Faction A support unit data—backline units (e.g., artillery) that can directly attack.
Format:

Unit Name | Quantity | Combat Points (HP) | Total Points


Bp.xlsx

Faction B bonus file—provides point bonuses during combat round calculations.
Note: Avoid negative total bonuses (untested).
Format:

Bonus Name | Bonus Points


Bunit.xlsx

Faction B frontline unit data—direct combat units deployed on the battlefield (frontline).
Format:

Unit Name | Quantity | Combat Points (HP) | Total Points


BunitS.xlsx

Faction B support unit data—backline units (e.g., artillery) that can directly attack.
Format:

Unit Name | Quantity | Combat Points (HP) | Total Points


Code Implementation Notes

The current build prioritizes functional implementation and has not undergone modularization or encapsulation. The scripts must be executed in MATLAB. It is strongly recommended to use MATLAB R2022b to avoid potential encoding issues.
