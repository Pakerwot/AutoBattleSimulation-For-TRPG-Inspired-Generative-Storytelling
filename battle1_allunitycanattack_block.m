%% 尝试对歼灭战的模拟进行函数封装，模块化（TODO）
% 此部分未完成，需要进行代码重构
%% 主程序
function main()
    % 初始化并读取数据
    [factionA, factionB, factionAS, factionBS, battleInfo] = load_data();
    
    % 预处理数据结构
    [dataA, dataB, dataAS, dataBS] = preprocess_data(factionA, factionB, factionAS, factionBS);
    
    % 显示战场信息
    display_battle_info(battleInfo, dataA, dataB, dataAS, dataBS);
    
    % 初始化战斗状态
    [stateA, stateB, stateAS, stateBS] = init_battle_state(dataA, dataB, dataAS, dataBS);
    
    % 执行战斗模拟
    [finalStateA, finalStateB, finalStateAS, finalStateBS, winner] = ...
        run_battle_simulation(dataA, dataB, dataAS, dataBS, stateA, stateB, stateAS, stateBS, battleInfo);
    
    % 生成并显示战斗报告
    generate_battle_report(finalStateA, finalStateB, finalStateAS, finalStateBS, battleInfo);
end

%% 数据加载函数
function [factionA, factionB, factionAS, factionBS, battleInfo] = load_data()
    % 读取Excel文件并设置列名
    factionA = readtable("Aunit.xlsx");
    factionB = readtable("Bunit.xlsx");
    factionAS = readtable("AunitS.xlsx");
    factionBS = readtable("BunitS.xlsx");
    battleInfo = readtable("Information.xlsx");
    
    % 设置列名（同原代码逻辑）
    % ...（具体实现同原代码的列名设置部分）...
end

%% 数据预处理函数
function [dataA, dataB, dataAS, dataBS] = preprocess_data(factionA, factionB, factionAS, factionBS)
    % 提取单位名称和数值数据
    % ...（同原代码的数据转换部分）...
    
    % 初始化数据结构体
    dataA = struct('unit_name', Aunit_name, 'unit_data', FA_unit_datalist);
    dataB = struct('unit_name', Bunit_name, 'unit_data', FB_unit_datalist);
    dataAS = struct('unit_name', AunitS_name, 'unit_data', FA_unitS_datalist);
    dataBS = struct('unit_name', BunitS_name, 'unit_data', FB_unitS_datalist);
end

%% 战斗状态初始化函数
function [stateA, stateB, stateAS, stateBS] = init_battle_state(dataA, dataB, dataAS, dataBS)
    % 初始化普通单位状态
    stateA = struct('health_list', init_health_list(dataA.unit_data), ...
                   'total_power', sum(dataA.unit_data(:,3)));
    stateB = struct('health_list', init_health_list(dataB.unit_data), ...
                   'total_power', sum(dataB.unit_data(:,3)));
    
    % 初始化支援单位状态
    stateAS = struct('health_list', init_support_health(dataAS.unit_data));
    stateBS = struct('health_list', init_support_health(dataBS.unit_data));
end

%% 战斗模拟核心函数
function [stateA, stateB, stateAS, stateBS, winner] = run_battle_simulation(...
    dataA, dataB, dataAS, dataBS, stateA, stateB, stateAS, stateBS, battleInfo)
    
    max_turns = min(battleInfo.A_max_turns, battleInfo.B_max_turns);
    winner = '';
    
    for turn = 1:max_turns
        % 支援单位攻击阶段
        [stateB, stateBS] = support_attack_phase(...
            dataAS, stateAS, dataB, stateB, dataBS, stateBS, battleInfo.factionA);
        
        [stateA, stateAS] = support_attack_phase(...
            dataBS, stateBS, dataA, stateA, dataAS, stateAS, battleInfo.factionB);
        
        % 地面部队攻击阶段
        [stateA, stateB, stateAS, stateBS] = ground_attack_phase(...
            dataA, dataB, stateA, stateB, stateAS, stateBS, battleInfo);
        
        % 胜负判定
        if check_victory(stateB)
            winner = battleInfo.factionA;
            return;
        elseif check_victory(stateA)
            winner = battleInfo.factionB;
            return;
        end
    end
end

%% 辅助函数：支援单位攻击
function [targetState, targetSupport] = support_attack_phase(...
    attackerData, attackerState, targetData, targetState, targetSupportData, targetSupport, factionName)
    
    for i = 1:size(attackerData.unit_data, 1)
        % 选择目标（普通单位或支援单位）
        [targetType, targetIdx] = select_target(targetState, targetSupport);
        
        % 执行攻击
        [damage, hit] = calculate_attack(attackerState.health_list(i,7));
        if hit
            apply_damage(targetType, targetIdx, damage, targetState, targetSupport);
        end
        
        % 更新状态
        update_unit_status(targetType, targetIdx, targetData, targetState, targetSupport);
    end
end

%% （其他辅助函数实现，包括select_target、calculate_attack、apply_damage等）

%% 生成战斗报告
function generate_battle_report(stateA, stateB, stateAS, stateBS, battleInfo)
    % 生成表格数据（同原代码逻辑）
    % 输出报告（同原代码显示逻辑）
    % 保存Excel文件（同原代码写入逻辑）
end

function [targetType, targetIdx] = select_target(state, supportState)
    validOrdinary = find(state.health_list(:,4) > 0);
    validSupport = find(supportState.health_list(:,4) > 0);
    allTargets = [validOrdinary; length(validOrdinary)+validSupport];
    
    if isempty(allTargets)
        error('没有可用目标');
    end
    
    selected = allTargets(randi(length(allTargets)));
    if selected <= length(validOrdinary)
        targetType = 'ordinary';
        targetIdx = selected;
    else
        targetType = 'support';
        targetIdx = selected - length(validOrdinary);
    end
end

function [damage, hit] = calculate_attack(maxDamage)
    damage = randi([0, maxDamage]);
    hit = (randi([0, 100]) >= 50);
end

function apply_damage(targetType, targetIdx, damage, state, supportState)
    if strcmp(targetType, 'ordinary')
        state.health_list(targetIdx,3) = state.health_list(targetIdx,3) - damage;
        if state.health_list(targetIdx,3) <= 0
            state.health_list(targetIdx,4) = 0;
        end
    else
        supportState.health_list(targetIdx,3) = supportState.health_list(targetIdx,3) - damage;
        if supportState.health_list(targetIdx,3) <= 0
            supportState.health_list(targetIdx,4) = 0;
        end
    end
end

% 示例结构体定义
factionData = struct(...
    'name', '阵营A',...
    'units', struct('name', {}, 'count', [], 'health', []),...
    'support', struct('name', {}, 'count', [], 'max_damage', [])...
);

classdef BattleUnit
    properties
        Name
        Count
        Health
        MaxDamage
        Status  % 0-被摧毁 1-存活
    end
    methods
        function obj = take_damage(obj, damage)
            obj.Health = obj.Health - damage;
            if obj.Health <= 0
                obj.Status = 0;
            end
        end
    end
end

function config = read_config(filename)
    config = jsondecode(fileread(filename));
end




