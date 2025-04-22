%% 2025.4.21
%% 据点争夺战模式，支援单位可以互相攻击，地面部队行动回合可以攻击支援单位
% 默认势力A为防守方，势力B为进攻方
%% 载入前初始化
clear all
close all
clc

%% 阵营单位文件读取
% 格式为 单位名 数量 战斗点数(生命) 总点数
FactionA =readtable("Aunit.xlsx");
FactionB =readtable("Bunit.xlsx");

FactionA.Properties.VariableNames={'单位名','数量','战斗点数(生命)','总点数'};
FactionB.Properties.VariableNames={'单位名','数量','战斗点数(生命)','总点数'};
%% 阵营支援单位读取
% 暂未使用 格式为 单位名 数量 战斗点数(生命) 总点数 弹药基数(可参与回合数) 支援冷却所需回合
% 格式为 单位名 数量 战斗点数(生命) 总点数
% 点数     100  200 1000
% 伤害上限 100  400 1000
%
FactionAS =readtable("AunitS.xlsx");
FactionBS =readtable("BunitS.xlsx");
FactionAS.Properties.VariableNames={'单位名','数量','战斗点数(生命)','总点数'};
FactionBS.Properties.VariableNames={'单位名','数量','战斗点数(生命)','总点数'};

%% 阵营加成文件读取
% 格式为 加成名 加成点数
FactionAp =readtable("Ap.xlsx");
FactionBp =readtable("Bp.xlsx");
FactionAp.Properties.VariableNames={'加成','加成点数'};
FactionBp.Properties.VariableNames={'加成','加成点数'};
%% 导入战斗场景文件
% 包含双方战斗胜利条件，场景信息
% 预留下一步结构，任务类型 0 歼灭战 1 攻坚战 2 防守战 3 护送任务 4 撤离任务
% 当前格式为 阵营 胜利条件 最大回合数 交战最大回合上限为20
Battleinfo = readtable("Information.xlsx");
Battleinfo.Properties.VariableNames ={'阵营','胜利条件','最大回合数'};
Faction_name_misson = table2array(Battleinfo(:,1:2));

% 导入战役信息说明
%% 导入地图文件
% 包含场地的地图据点控制情况
%% 导入据点控制权数据
StrongholdData = readtable("bfset.xlsx");
StrongholdData.Properties.VariableNames = {'据点名称', '控制权'};
disp('初始据点控制权：');
disp(StrongholdData);

%% 数据文件转矩阵储存
% 地面作战单位信息(可被攻击)
FA_unit_name = FactionA(:,1);
Aunit_name = table2array(FA_unit_name);
FA_unit_data = FactionA(:,2:4);
FA_size = size(FA_unit_data);
FA_unit_datalist = table2array(FA_unit_data);

FB_unit_name = FactionB(:,1);
Bunit_name = table2array(FB_unit_name);
FB_unit_data = FactionB(:,2:4);
FB_size = size(FB_unit_data);
FB_unit_datalist = table2array(FB_unit_data);

% 支援单位信息
FA_unitS_name = FactionAS(:,1);
AunitS_name = table2array(FA_unitS_name);
FA_unitS_data = FactionAS(:,2:4);
FAS_size = size(FA_unitS_data);
FA_unitS_datalist = table2array(FA_unitS_data);

FB_unitS_name = FactionBS(:,1);
BunitS_name = table2array(FB_unitS_name);
FB_unitS_data = FactionBS(:,2:4);
FBS_size = size(FB_unitS_data);
FB_unitS_datalist = table2array(FB_unitS_data);

% 加成信息
FA_P_name = FactionAp(:,1);
AP_name = table2array(FA_P_name);
FA_P_data = FactionAp(:,2);
FAP_size = size(FA_P_data);
FA_P_datalist = table2array(FA_P_data);

FB_P_name = FactionBp(:,1);
BP_name = table2array(FB_P_name);
FB_P_data = FactionBp(:,2);
FBP_size = size(FB_P_data);
FB_P_datalist = table2array(FB_P_data);

% 据点信息
% Pointnames=StrongholdData(:,1);
% Pointname = table2array(Pointnames);
% Pointname =StrongholdData(:,1);
Pointname =table2array(StrongholdData(:,1));
Pointcontrol = table2array(StrongholdData(:,2));
%% 显示双方阵营情况，以及战斗信息说明
% 战役信息说明

% 战役胜利条件说明

% 双方阵营作战单位说明
flagAS = 0;
flagBS = 0;
fprintf('阵营A: %s\n', Faction_name_misson{1,1});
disp('作战单位:');
disp(FactionA);

disp('支援单位:');
if ~isempty(FactionAS)  % 确保FactionAS非空
    flagAS = 1;
    disp(FactionAS);
else
    disp('没有支援单位');
end


fprintf('阵营B: %s\n', Faction_name_misson{2,1});
disp('作战单位:');
disp(FactionB);
disp('支援单位:');
if ~isempty(FactionBS)  % 确保FactionBS非空
    flagBS = 1;
    disp(FactionBS);
else
    disp('没有支援单位');
end

% 双方加成说明

% 其他信息说明

%% 判定列表内是否存在特殊单位
% 未使用以及未完善
% special_units = {'特殊单位A', '特殊单位B'}; % 替换为你具体的特殊单位
% FA_special_units = ismember(FA_unit_name, special_units);
% FB_special_units = ismember(FB_unit_name, special_units);
%
% if any(FA_special_units)
%     disp('阵营A中存在特殊单位');
% end
% if any(FB_special_units)
%     disp('阵营B中存在特殊单位');
% end

%% 执行初始化计算，计算双方点数以及数据情况
% 健康数据表 单位总数量 点数 总点数 完整单位 受损 被摧毁
Aunit_health_list =zeros(FA_size(1),6);
Bunit_health_list =zeros(FB_size(1),6);
Aunit_health_list(:,1:3)=FA_unit_datalist;
Bunit_health_list(:,1:3)=FB_unit_datalist;
Aunit_health_list(:,4)=FA_unit_datalist(:,1);
Bunit_health_list(:,4)=FB_unit_datalist(:,1);

% 支援单位分配伤害表
% 点数     100 100~200 200 1000
% 伤害上限 100  200    400 1000
% 健康数据表 单位总数量 点数 总点数 完整单位 受损 被摧毁 杀伤判定上限
AunitS_health_list =zeros(FAS_size(1),7);
AunitS_health_list(:,1:3)=FA_unitS_datalist;
AunitS_health_list(:,4)=FA_unitS_datalist(:,1);
for i = 1:FAS_size(1)
    if AunitS_health_list(i,2) <=100
        AunitS_health_list(i,7)=100;
    elseif AunitS_health_list(i,2)>100 && AunitS_health_list(i,2)<200
        AunitS_health_list(i,7)=200;
    elseif AunitS_health_list(i,2)>=200 && AunitS_health_list(i,2)<1000
        AunitS_health_list(i,7)=400;
    elseif AunitS_health_list(i,2) >=1000
        AunitS_health_list(i,7)=1000;
    end
end
BunitS_health_list =zeros(FBS_size(1),7);
BunitS_health_list(:,1:3)=FB_unitS_datalist;
BunitS_health_list(:,4)=FB_unitS_datalist(:,1);
for i = 1:FBS_size(1)
    if BunitS_health_list(i,2) <=100
        BunitS_health_list(i,7)=100;
    elseif BunitS_health_list(i,2)>100 && BunitS_health_list(i,2)<200
        BunitS_health_list(i,7)=200;
    elseif BunitS_health_list(i,2)>=200 && BunitS_health_list(i,2)<1000
        BunitS_health_list(i,7)=400;
    elseif BunitS_health_list(i,2) >=1000
        BunitS_health_list(i,7)=1000;
    end
end

% 战斗力(生命）总和计算
FA_health_power=sum(Aunit_health_list(:,3));
FB_health_power=sum(Bunit_health_list(:,3));

% 加成总和计算
FAp_sum = sum(FA_P_datalist);
FBp_sum = sum(FB_P_datalist);

% 0 歼灭战/总力战用
% 初始化回合数
nAmax = table2array(Battleinfo(1,3));
nBmax = table2array(Battleinfo(2,3));
nmin = min(nAmax,nBmax);
max_turns = nmin;


%% 执行战斗对抗
% 阵营胜利标识旗
FAwinFlag=0;
FBwinFlag=0;
hitFlag=0;
for turn = 1:max_turns
    % 每回合的伤害只计算一线部队，支援部队的血量不包括
    FA_turn_damge = 0;
    FB_turn_damge = 0;

    % 回合行动指令
    FA_Action = 0;
    FB_Action = 0;

    disp('========================');
    disp(['第', num2str(turn), '回合开始']);
    disp('========================');
    disp('-------------------');
    disp('支援单位行动阶段');

    if flagAS ==1
        fprintf([Faction_name_misson{1,1},'支援单位行动:\n'])
        for i = 1: FAS_size(1)
            if AunitS_health_list (i, 4) == 0
                continue
            end
            % 初始化
            hitFlag=0;
            fprintf([AunitS_name{i,1},'行动:\n'])

            % 获取所有存活目标（普通+支援）
            valid_ordinary = find(Bunit_health_list(:,4) > 0);
            valid_support = find(BunitS_health_list(:,4) > 0);
            valid_targets = [valid_ordinary; FB_size(1) + valid_support];


            % 支援单位目标选取
            % 禁止鞭尸
            %             if
            %             end
            %             target_B = randi([1, FB_size(1)]);  % 随机选择阵营B的单位作为目标
            %             if Bunit_health_list (target_B, 4) == 0
            %                 while Bunit_health_list (target_B, 4) ~= 0
            %                     target_B = randi([1, FB_size(1)]);
            %                 end
            %             end
            %             fprintf(['Rd',num2str(FB_size(1)),'=', num2str(target_B),'\n']);
            %             fprintf([Bunit_name{target_B,1},' 被选为攻击目标\n']);
            if isempty(valid_targets)
                fprintf('所有目标已被摧毁，无法攻击\n');
                continue;
            else
                % selected = valid_targets(randi(length(valid_targets)));
                selected = randi([1,FB_size(1)+FBS_size(1)]);
                fflag=0;
                while fflag == 0
                    if selected <= FB_size(1)
                        target_B = selected;
                        if Bunit_health_list (target_B, 4) ~= 0
                            fflag=1;
                        else
                            selected = randi([1,FB_size(1)+FBS_size(1)]);
                        end
                    else
                        target_B_support = selected - FB_size(1);
                        if BunitS_health_list (target_B_support, 4) ~= 0
                            fflag=1;
                        else
                            selected = randi([1,FB_size(1)+FBS_size(1)]);
                        end
                    end
                end

                if selected <= FB_size(1)
                    target_B = selected;
                    target_type = '普通';
                    fprintf(['Rd',num2str(FB_size(1)),'=', num2str(target_B),'\n']);
                    fprintf(['目标类型:', target_type, ' ',Bunit_name{target_B,1},' 被选为攻击目标\n']);
                else
                    target_B_support = selected - FB_size(1);
                    target_type = '支援';
                    fprintf(['Rd',num2str(FBS_size(1)),'=', num2str(target_B_support),'\n']);
                    fprintf(['目标类型:', target_type, ' ',BunitS_name{target_B_support,1},' 被选为攻击目标\n']);
                end
            end

            % 支援单位杀伤判定
            FA_damage = randi([0, AunitS_health_list(i,7)]);  % 这是随机生成的伤害


            fprintf('单位杀伤判定\n');
            fprintf(['Rd',num2str(AunitS_health_list(i,7)),'=', num2str(FA_damage),'\n']);

            % 杀伤效果评估(命中判定)
            hit = randi([0, 100]);
            fprintf('单位命中判定\n');
            fprintf(['Rd100','=', num2str(hit),'\n']);
            if hit >= 50
                hitFlag=1;
            end
            if hitFlag == 1
                %                 % 更新伤害后的受损生命
                %                 Bunit_health_list(target_B, 3) = Bunit_health_list(target_B, 3) - FA_damage;
                %                 fprintf([AunitS_name{i,1},' 攻击命中目标\n']);
                %                 fprintf([Faction_name_misson{2,1},'的', Bunit_name{target_B,1}, '受到了', num2str(FA_damage), '点伤害\n\n']);
                %                 % disp([Faction_name_misson(2,1), FB_unit_name(target_B,1), '受到了', num2str(FA_damage), '点伤害']);
                %
                %                 % 单位损失判定
                %                 % 判断是否有单位被消灭（生命值降为0或以下）
                %                 % 暂时不考虑受损单位存在，直接判定被摧毁
                %                 if Bunit_health_list(target_B, 3) <= 0
                %                     % disp(['阵营A的', FA_unit_name{target_A}, '被消灭!']);
                %                     fprintf([Faction_name_misson{2,1},'的', Bunit_name{target_B,1}, '被消灭！\n']);
                %                     Bunit_health_list (target_B, 6) = Bunit_health_list (target_B, 4);
                %                     Bunit_health_list (target_B, 4) = 0; % 单位存活状态更新
                %
                %                 end
                % 根据目标类型更新伤害
                if strcmp(target_type, '普通')
                    FA_turn_damge = FA_turn_damge + FA_damage;
                    Bunit_health_list(target_B, 3) = Bunit_health_list(target_B, 3) - FA_damage;
                    fprintf([Faction_name_misson{2,1},'的', Bunit_name{target_B,1}, '受到了', num2str(FA_damage), '点伤害\n\n']);
                    % 普通单位摧毁判定
                    if Bunit_health_list(target_B, 3) <= 0
                        fprintf([Faction_name_misson{2,1},'的', Bunit_name{target_B,1}, '被消灭！\n']);
                        Bunit_health_list(target_B, 6) = Bunit_health_list(target_B, 4);
                        Bunit_health_list(target_B, 4) = 0;
                    end
                else
                    BunitS_health_list(target_B_support, 3) = BunitS_health_list(target_B_support, 3) - FA_damage;
                    fprintf([Faction_name_misson{2,1},'的支援单位', BunitS_name{target_B_support,1}, '受到了', num2str(FA_damage), '点伤害\n\n']);
                    % 支援单位摧毁判定
                    if BunitS_health_list(target_B_support, 3) <= 0
                        fprintf([Faction_name_misson{2,1},'的支援单位', BunitS_name{target_B_support,1}, '被消灭！\n']);
                        BunitS_health_list(target_B_support, 6) = BunitS_health_list(target_B_support, 4);
                        BunitS_health_list(target_B_support, 4) = 0;
                    end
                end

                % 敌方支援单位情况判定
                if flagBS~=0 && sum(BunitS_health_list(:,4)) == 0
                    fprintf([Faction_name_misson{2,1},'支援单位已全部损失\n']);
                    flagBS=0;
                end

                % 胜利条件判断
                if sum(Bunit_health_list(:,4)) == 0
                    fprintf([Faction_name_misson{2,1},'已无作战单位可用', Faction_name_misson{1,1}, '取得胜利\n']);
                    FAwinFlag=1;
                    break;
                end


            else
                fprintf([AunitS_name{i,1},' 攻击未命中\n\n']);
            end
        end
    else
        fprintf([Faction_name_misson{1,1},'无支援单位可用，阶段跳过\n']);
    end
    % 支援单位目标选取

    % 支援单位杀伤判定

    % 杀伤效果评估(命中判定)
    if flagBS ==1
        fprintf([Faction_name_misson{2,1},'支援单位行动:\n']);
        for i = 1: FBS_size(1)
            if BunitS_health_list (i, 4) == 0
                continue
            end
            % 初始化
            hitFlag=0;
            fprintf([BunitS_name{i,1},'行动:\n'])

            %
            %             % 支援单位目标选取
            %             target_A = randi([1, FA_size(1)]);  % 随机选择阵营A的单位作为目标
            %             if Aunit_health_list (target_A, 4) == 0
            %                 while Aunit_health_list (target_A, 4) ~= 0
            %                     target_A = randi([1, FA_size(1)]);
            %                 end
            %             end
            %             fprintf(['Rd',num2str(FA_size(1)),'=', num2str(target_A),'\n']);
            %             fprintf([Aunit_name{target_A,1},' 被选为攻击目标\n']);

            % 获取所有存活目标（普通+支援）
            valid_ordinary = find(Aunit_health_list(:,4) > 0);
            valid_support = find(AunitS_health_list(:,4) > 0);
            valid_targets = [valid_ordinary; FB_size(1) + valid_support];


            % 支援单位目标选取
            % 禁止鞭尸
            %             if
            %             end
            %             target_B = randi([1, FB_size(1)]);  % 随机选择阵营B的单位作为目标
            %             if Bunit_health_list (target_B, 4) == 0
            %                 while Bunit_health_list (target_B, 4) ~= 0
            %                     target_B = randi([1, FB_size(1)]);
            %                 end
            %             end
            %             fprintf(['Rd',num2str(FB_size(1)),'=', num2str(target_B),'\n']);
            %             fprintf([Bunit_name{target_B,1},' 被选为攻击目标\n']);
            if isempty(valid_targets)
                fprintf('所有目标已被摧毁，无法攻击\n');
                continue;
            else
                % selected = valid_targets(randi(length(valid_targets)));
                selected = randi([1,FA_size(1)+FAS_size(1)]);
                fflag=0;
                while fflag == 0
                    if selected <= FA_size(1)
                        target_A = selected;
                        if Aunit_health_list (target_A, 4) ~= 0
                            fflag=1;
                        else
                            selected = randi([1,FA_size(1)+FAS_size(1)]);
                        end
                    else
                        target_A_support = selected - FA_size(1);
                        if AunitS_health_list (target_A_support, 4) ~= 0
                            fflag=1;
                        else
                            selected = randi([1,FA_size(1)+FAS_size(1)]);
                        end
                    end
                end
                if selected <= FA_size(1)
                    target_A = selected;
                    target_type = '普通';

                    fprintf(['Rd',num2str(FA_size(1)),'=', num2str(target_A),'\n']);
                    fprintf(['目标类型:', target_type, ' ',Aunit_name{target_A,1},' 被选为攻击目标\n']);
                else
                    target_A_support = selected - FA_size(1);
                    target_type = '支援';

                    fprintf(['Rd',num2str(FAS_size(1)),'=', num2str(target_A_support),'\n']);
                    fprintf(['目标类型:', target_type, ' ',AunitS_name{target_A_support,1},' 被选为攻击目标\n']);
                end
            end

            % 支援单位杀伤判定
            FB_damage = randi([0, BunitS_health_list(i,7)]);  % 这是随机生成的伤害

            fprintf('单位杀伤判定\n');
            fprintf(['Rd',num2str(AunitS_health_list(i,7)),'=', num2str(FB_damage),'\n']);

            % 杀伤效果评估(命中判定)
            hit = randi([0, 100]);
            if hit >= 50
                hitFlag=1;
            end
            fprintf('单位命中判定\n');
            fprintf(['Rd100','=', num2str(hit),'\n']);
            if hitFlag == 1

                %                 % 更新伤害后的受损生命
                %                 Aunit_health_list(target_A, 3) = Aunit_health_list(target_A, 3) - FB_damage;
                %                 fprintf([BunitS_name{i,1},' 攻击命中目标\n']);
                %                 fprintf([Faction_name_misson{1,1},'的', Aunit_name{target_A,1}, '受到了', num2str(FB_damage), '点伤害\n\n']);
                %                 % disp([Faction_name_misson(2,1), FB_unit_name(target_B,1), '受到了', num2str(FA_damage), '点伤害']);
                %
                %                 % 单位损失判定
                %                 % 判断是否有单位被消灭（生命值降为0或以下）
                %                 % 暂时不考虑受损单位存在，直接判定被摧毁
                %                 if Aunit_health_list(target_A, 3) <= 0
                %                     % disp(['阵营A的', FA_unit_name{target_A}, '被消灭!']);
                %                     fprintf([Faction_name_misson{1,1},'的', Aunit_name{target_A,1}, '被消灭！\n']);
                %                     Aunit_health_list(target_A, 6) = Aunit_health_list(target_A, 4);
                %                     Aunit_health_list(target_A, 4) = 0; % 单位存活状态更新
                %
                %                 end

                % 根据目标类型更新伤害
                if strcmp(target_type, '普通')
                    FB_turn_damge = FB_turn_damge + FB_damage;
                    Aunit_health_list(target_A, 3) = Aunit_health_list(target_A, 3) - FB_damage;
                    fprintf([Faction_name_misson{2,1},'的', Aunit_name{target_A,1}, '受到了', num2str(FB_damage), '点伤害\n\n']);
                    % 普通单位摧毁判定
                    if Aunit_health_list(target_A, 3) <= 0
                        fprintf([Faction_name_misson{1,1},'的', Aunit_name{target_A,1}, '被消灭！\n']);
                        Aunit_health_list(target_A, 6) = Aunit_health_list(target_A, 4);
                        Aunit_health_list(target_A, 4) = 0;
                    end
                else
                    AunitS_health_list(target_A_support, 3) = AunitS_health_list(target_A_support, 3) - FB_damage;
                    fprintf([Faction_name_misson{1,1},'的支援单位', AunitS_name{target_A_support,1}, '受到了', num2str(FB_damage), '点伤害\n\n']);
                    % 支援单位摧毁判定
                    if AunitS_health_list(target_A_support, 3) <= 0
                        fprintf([Faction_name_misson{2,1},'的支援单位', AunitS_name{target_A_support,1}, '被消灭！\n']);
                        AunitS_health_list(target_A_support, 6) = AunitS_health_list(target_A_support, 4);
                        AunitS_health_list(target_A_support, 4) = 0;
                    end
                end

            else
                fprintf([BunitS_name{i,1},' 攻击未命中\n\n']);
            end
            % 敌方支援单位情况判定
            if  flagAS~=0 && sum(AunitS_health_list(:,4)) == 0
                fprintf([Faction_name_misson{1,1},'支援单位已全部损失\n']);
                flagAS=0;
            end

            % 胜利条件判定
            if sum(Aunit_health_list(:,4)) == 0
                fprintf([Faction_name_misson{1,1},'已无作战单位可用', Faction_name_misson{2,1}, '取得胜利\n']);
                FBwinFlag=1;
                break;
            end
        end
    else
        fprintf([Faction_name_misson{2,1},'无支援单位可用，阶段跳过\n']);
    end

    if FAwinFlag==1
        disp('************************************************************')
        fprintf([Faction_name_misson{2,1},'已无作战单位可用', Faction_name_misson{1,1}, '取得胜利\n']);
        disp('************************************************************')
        break;
    elseif FBwinFlag==1
        disp('************************************************************')
        fprintf([Faction_name_misson{1,1},'已无作战单位可用', Faction_name_misson{2,1}, '取得胜利\n']);
        disp('************************************************************')
        break;
    end
    % 战斗点数判定
    % 差值判定杀伤上限
    % 点数     100~400 400~800 800~1000 1000+
    % 伤害上限 100      200    400      500

    disp('-------------------------------------------------------------')
    disp('地面部队行动阶段');
    FA_Point = FAp_sum + randi([1,FA_health_power]);
    FB_Point = FBp_sum + randi([1,FB_health_power]);
    fprintf([Faction_name_misson{1,1},': Rd', num2str(FA_health_power), '+',num2str(FAp_sum),'=',num2str(FA_Point),'\n']);
    fprintf([Faction_name_misson{2,1},': Rd', num2str(FB_health_power), '+',num2str(FBp_sum),'=',num2str(FB_Point),'\n']);

    % 判定行动权
    if FA_Point > FB_Point
        FA_Action = 1;
        fprintf([Faction_name_misson{1,1},'获得回合行动杀伤权\n']);
        fprintf([Faction_name_misson{1,1},'获得回合行动战场主动权\n']);
        fprintf([Faction_name_misson{1,1},'战术策略： 进攻\n']);
        fprintf([Faction_name_misson{2,1},'战术策略： 防守\n']);
    elseif FA_Point < FB_Point
        FB_Action = 1;
        fprintf([Faction_name_misson{2,1},'获得回合行动杀伤权\n']);
        fprintf([Faction_name_misson{2,1},'获得回合行动战场主动权\n']);
        fprintf([Faction_name_misson{1,1},'战术策略： 防守\n']);
        fprintf([Faction_name_misson{2,1},'战术策略： 进攻\n']);
    else
        FA_Action = 1;
        FB_Action = 1;
        fprintf([Faction_name_misson{1,1},' 与 ',Faction_name_misson{2,1},'同时获得回合行动杀伤权\n']);
        fprintf(['战况激烈 ',Faction_name_misson{1,1},' 与 ',Faction_name_misson{2,1},'同时发起攻势\n']);
        fprintf([Faction_name_misson{1,1},'战术策略： 进攻\n']);
        fprintf([Faction_name_misson{2,1},'战术策略： 进攻\n']);
    end

    % 判定回合杀伤上限
    check = abs(FA_Point-FB_Point);

    if check == 0 || check >= 1000
        Max_damge = 500;
        pointcontrolmax = 5;
        Max_attack= 500;
        Max_defence= 500;
        fprintf(['基于差值情况，本回合的最大杀伤上限为',num2str(Max_damge),'\n']);
        fprintf(['基于差值情况，本回合的最大进攻值上限为',num2str(Max_attack),'\n']);
        fprintf(['基于差值情况，本回合的最大防御值上限为',num2str(Max_defence),'\n']);
        fprintf(['基于差值情况，本回合的最大可进攻据点次数上限为',num2str(pointcontrolmax),'\n']);
    elseif check < 400 && check >0
        Max_damge = 100;
        pointcontrolmax = 1;
        Max_attack= 100;
        Max_defence= 150;
        fprintf(['基于差值情况，本回合的最大杀伤上限为',num2str(Max_damge),'\n']);
        fprintf(['基于差值情况，本回合的最大进攻值上限为',num2str(Max_attack),'\n']);
        fprintf(['基于差值情况，本回合的最大防御值上限为',num2str(Max_defence),'\n']);
        fprintf(['基于差值情况，本回合的最大可进攻据点次数上限为',num2str(pointcontrolmax),'\n']);
    elseif check >= 400 && check < 800
        pointcontrolmax = 2;
        Max_damge = 200;
        Max_attack= 200;
        Max_defence= 200;
        fprintf(['基于差值情况，本回合的最大杀伤上限为',num2str(Max_damge),'\n']);
        fprintf(['基于差值情况，本回合的最大进攻值上限为',num2str(Max_attack),'\n']);
        fprintf(['基于差值情况，本回合的最大防御值上限为',num2str(Max_defence),'\n']);
        fprintf(['基于差值情况，本回合的最大可进攻据点次数上限为',num2str(pointcontrolmax),'\n']);
    elseif check >= 800 && check < 1000
        Max_damge = 400;
        pointcontrolmax = 4;
        Max_attack= 150;
        Max_defence= 100;
        fprintf(['基于差值情况，本回合的最大杀伤上限为',num2str(Max_damge),'\n']);
        fprintf(['基于差值情况，本回合的最大进攻值上限为',num2str(Max_attack),'\n']);
        fprintf(['基于差值情况，本回合的最大防御值上限为',num2str(Max_defence),'\n']);
        fprintf(['基于差值情况，本回合的最大可进攻据点次数上限为',num2str(pointcontrolmax),'\n']);
    end

%% 战区点夺取判定
    pointatkmax=min(pointcontrolmax,size(Pointcontrol,2));
    
    for paki=1:pointatkmax
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        disp(['该回合据点攻防第 ', num2str(paki), ' 轮交锋开始']);
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        disp('-------------------');
        if FA_Action == 1
            % FA_Action = 1; FA_Point > FB_Point
            % 据点夺取判定（阵营A）
            attacker = 1;
            defender = 2;
            available_strongholds_indices = find(Pointcontrol ~= attacker);
            if ~isempty(available_strongholds_indices)
                selected_available_index = randi(length(available_strongholds_indices));
                selected_original_index = available_strongholds_indices(selected_available_index);
                selected_point_name=Pointname(selected_original_index,1);
                % selected_stronghold = StrongholdData(selected_original_index, :);
                % fprintf('尝试夺取据点：%s，当前控制权：%d\n', selected_stronghold.("据点名称"){1}, selected_stronghold.("控制权"));
    
                attack_roll = randi([1, Max_attack]);
                defense_roll = randi([1, Max_defence]);

                if Pointcontrol(selected_original_index,1) == 0
                    fprintf('%s 尝试夺取据点：%s，当前控制权：中立\n', Faction_name_misson{1,1},Pointname{selected_original_index,1});
                else
                    fprintf('%s 尝试夺取据点：%s，当前控制权：%s\n', Faction_name_misson{1,1},Pointname{selected_original_index,1}, Faction_name_misson{2,1});
                end
                fprintf('攻击方判定值：%d，防守方防御值：%d\n', attack_roll, defense_roll);
                
                if Pointcontrol(selected_original_index,1) == 0
                    if attack_roll >= defense_roll
                        Pointcontrol(selected_original_index,1) = attacker;
                        fprintf('攻击方成功夺取据点！%s 现在由 %s 控制。\n', Pointname{selected_original_index,1},Faction_name_misson{1,1});
                    else
                        fprintf('攻击方未能夺取中立据点，保持中立。\n');
                    end
                else
                    if attack_roll > defense_roll
                        Pointcontrol(selected_original_index,1) = attacker;
                        fprintf('攻击方成功夺取据点！%s 现在由 %s 控制。\n', Pointname{selected_original_index,1},Faction_name_misson{1,1});
                    else
                        fprintf('攻击方未能夺取据点，仍由 %s 控制。\n',Faction_name_misson{2,1});
                    end
                end
            else
                fprintf('没有可夺取的据点。\n');
                fprintf('所有目标依然由 %s 控制\n', Faction_name_misson{1,1});
            end
        end
        if FB_Action==1
            % FB_Action = 1; FA_Point < FB_Point
            
            % 据点夺取判定（阵营B）
            attacker = 2;
            defender = 1;
            available_strongholds_indices = find(Pointcontrol ~= attacker);
            if ~isempty(available_strongholds_indices)
                selected_available_index = randi(length(available_strongholds_indices));
                selected_original_index = available_strongholds_indices(selected_available_index);
                selected_point_name=Pointname(selected_original_index,1);
                % fprintf('尝试夺取据点：%s，当前控制权：%d\n', selected_stronghold.据点名称{1}, selected_stronghold.控制权);
                
                attack_roll = randi([1, Max_attack]);
                defense_roll = randi([1, Max_defence]);

                if Pointcontrol(selected_original_index,1) == 0
                    fprintf('%s 尝试夺取据点：%s，当前控制权：中立\n',Faction_name_misson{2,1}, Pointname{selected_original_index,1});
                else
                    fprintf('%s 尝试夺取据点：%s，当前控制权：%s\n', Faction_name_misson{2,1}, Pointname{selected_original_index,1}, Faction_name_misson{1,1});
                end
                fprintf('攻击方判定值：%d，防守方防御值：%d\n', attack_roll, defense_roll);
                
                if Pointcontrol(selected_original_index,1) == 0
                    if attack_roll >= defense_roll
                        Pointcontrol(selected_original_index,1) = attacker;
                        fprintf('攻击方成功夺取据点！%s 现在由 %s 控制。\n', Pointname{selected_original_index,1},Faction_name_misson{2,1});
                    else
                        fprintf('攻击方未能夺取中立据点，保持中立。\n');
                    end
                else
                    if attack_roll > defense_roll
                        Pointcontrol(selected_original_index,1) = attacker;
                        fprintf('攻击方成功夺取据点！%s 现在由 %s 控制。\n', Pointname{selected_original_index,1},Faction_name_misson{2,1});
                    else
                        fprintf('攻击方未能夺取据点，仍由 %s 控制。\n',Faction_name_misson{1,1});
                    end
                end
            else
                fprintf('没有可夺取的据点。\n');
                fprintf('所有目标已经被 %s 控制, %s 取得胜利\n',Faction_name_misson{2,1},Faction_name_misson{2,1});
                FBwinFlag=1;
                break;
            end

        end
    end

%% 单位损伤判断
    if FA_Action ==1
        % 初始化
        hitFlag=0;
        % 支援单位目标选取
        % 禁止鞭尸
        %             if
        %             end
        %         target_B = randi([1, FB_size(1)]);  % 随机选择阵营B的单位作为目标
        %         if Bunit_health_list (target_B, 4) == 0
        %             while Bunit_health_list (target_B, 4) ~= 0
        %                 target_B = randi([1, FB_size(1)]);
        %             end
        %         end
        %         fprintf(['Rd',num2str(FB_size(1)),'=', num2str(target_B),'\n']);
        %         fprintf([Bunit_name{target_B,1},' 被选为攻击目标\n']);
        % 获取所有存活目标（普通+支援）
        valid_ordinary = find(Bunit_health_list(:,4) > 0);
        valid_support = find(BunitS_health_list(:,4) > 0);
        valid_targets = [valid_ordinary; FB_size(1) + valid_support];

        if isempty(valid_targets)
            fprintf('所有目标已被摧毁，无法攻击\n');
            continue;
        else
            % selected = valid_targets(randi(length(valid_targets)));
            selected = randi([1,FB_size(1)+FBS_size(1)]);
            fflag=0;
            while fflag == 0
                if selected <= FB_size(1)
                    target_B = selected;
                    if Bunit_health_list (target_B, 4) ~= 0
                        fflag=1;
                    else
                        selected = randi([1,FB_size(1)+FBS_size(1)]);
                    end
                else
                    target_B_support = selected - FB_size(1);
                    if BunitS_health_list (target_B_support, 4) ~= 0
                        fflag=1;
                    else
                        selected = randi([1,FB_size(1)+FBS_size(1)]);
                    end
                end
            end

            if selected <= FB_size(1)
                target_B = selected;
                target_type = '普通';
                fprintf(['Rd',num2str(FB_size(1)),'=', num2str(target_B),'\n']);
                fprintf(['目标类型:', target_type, ' ',Bunit_name{target_B,1},' 被选为攻击目标\n']);
            else
                target_B_support = selected - FB_size(1);
                target_type = '支援';
                fprintf(['Rd',num2str(FBS_size(1)),'=', num2str(target_B_support),'\n']);
                fprintf(['目标类型:', target_type, ' ',BunitS_name{target_B_support,1},' 被选为攻击目标\n']);
            end
        end

        % 单位杀伤判定
        FA_damage = randi([0, Max_damge]);  % 这是随机生成的伤害

        fprintf('单位杀伤判定\n');
        fprintf(['Rd',num2str(Max_damge),'=', num2str(FA_damage),'\n']);

        % 杀伤效果评估(命中判定)
        hit = randi([0, 100]);
        fprintf('单位命中判定\n');
        fprintf(['Rd100','=', num2str(hit),'\n']);
        if hit >= 50
            hitFlag=1;
        end
        if hitFlag == 1
            %             FA_turn_damge = FA_turn_damge + FA_damage;
            %             % 更新伤害后的受损生命
            %             Bunit_health_list(target_B, 3) = Bunit_health_list(target_B, 3) - FA_damage;
            %             %fprintf([AunitS_name{i,1},' 攻击命中目标\n']);
            %             fprintf([Faction_name_misson{2,1},'的', Bunit_name{target_B,1}, '受到了', num2str(FA_damage), '点伤害\n\n']);
            %             % disp([Faction_name_misson(2,1), FB_unit_name(target_B,1), '受到了', num2str(FA_damage), '点伤害']);
            %
            %             % 单位损失判定
            %             % 判断是否有单位被消灭（生命值降为0或以下）
            %             % 暂时不考虑受损单位存在，直接判定被摧毁
            %             if Bunit_health_list(target_B, 3) <= 0
            %                 % disp(['阵营A的', FA_unit_name{target_A}, '被消灭!']);
            %                 fprintf([Faction_name_misson{2,1},'的', Bunit_name{target_B,1}, '被消灭！\n']);
            %                 Bunit_health_list (target_B, 6) = Bunit_health_list (target_B, 4);
            %                 Bunit_health_list (target_B, 4) = 0; % 单位存活状态更新
            %
            %             end

            % 根据目标类型更新伤害
            % 单位损失判定
            % 判断是否有单位被消灭（生命值降为0或以下）
            % 暂时不考虑受损单位存在，直接判定被摧毁
            if strcmp(target_type, '普通')
                FA_turn_damge = FA_turn_damge + FA_damage;
                Bunit_health_list(target_B, 3) = Bunit_health_list(target_B, 3) - FA_damage;
                fprintf([Faction_name_misson{2,1},'的', Bunit_name{target_B,1}, '受到了', num2str(FA_damage), '点伤害\n\n']);
                % 普通单位摧毁判定
                if Bunit_health_list(target_B, 3) <= 0
                    fprintf([Faction_name_misson{2,1},'的', Bunit_name{target_B,1}, '被消灭！\n']);
                    Bunit_health_list(target_B, 6) = Bunit_health_list(target_B, 4);
                    Bunit_health_list(target_B, 4) = 0;
                end
            else
                BunitS_health_list(target_B_support, 3) = BunitS_health_list(target_B_support, 3) - FA_damage;
                fprintf([Faction_name_misson{2,1},'的支援单位', BunitS_name{target_B_support,1}, '受到了', num2str(FA_damage), '点伤害\n\n']);
                % 支援单位摧毁判定
                if BunitS_health_list(target_B_support, 3) <= 0
                    fprintf([Faction_name_misson{2,1},'的支援单位', BunitS_name{target_B_support,1}, '被消灭！\n']);
                    BunitS_health_list(target_B_support, 6) = BunitS_health_list(target_B_support, 4);
                    BunitS_health_list(target_B_support, 4) = 0;
                end
            end

            % 敌方支援单位情况判定
            if flagBS~=0 && sum(BunitS_health_list(:,4)) == 0
                fprintf([Faction_name_misson{2,1},'支援单位已全部损失\n']);
                flagBS=0;
            end
            % 胜利条件判断
            if sum(Bunit_health_list(:,4)) == 0
                fprintf([Faction_name_misson{2,1},'已无作战单位可用', Faction_name_misson{1,1}, '取得胜利\n']);
                FAwinFlag=1;
                break;
            end


        else
            fprintf([Faction_name_misson{1,1},' 攻击未命中\n\n']);
        end
    end

    if FB_Action == 1
        % 初始化
        hitFlag=0;
        % 支援单位目标选取
        %         target_A = randi([1, FA_size(1)]);  % 随机选择阵营A的单位作为目标
        %         if Aunit_health_list (target_A, 4) == 0
        %             while Aunit_health_list (target_A, 4) ~= 0
        %                 target_A = randi([1, FA_size(1)]);
        %             end
        %         end
        %         fprintf(['Rd',num2str(FA_size(1)),'=', num2str(target_A),'\n']);
        %         fprintf([Aunit_name{target_A,1},' 被选为攻击目标\n']);
        % 获取所有存活目标（普通+支援）
        valid_ordinary = find(Aunit_health_list(:,4) > 0);
        valid_support = find(AunitS_health_list(:,4) > 0);
        valid_targets = [valid_ordinary; FB_size(1) + valid_support];

        % 目标选取
        if isempty(valid_targets)
            fprintf('所有目标已被摧毁，无法攻击\n');
            continue;
        else
            % selected = valid_targets(randi(length(valid_targets)));
            selected = randi([1,FA_size(1)+FAS_size(1)]);
            fflag=0;
            while fflag == 0
                if selected <= FA_size(1)
                    target_A = selected;
                    if Aunit_health_list (target_A, 4) ~= 0
                        fflag=1;
                    else
                        selected = randi([1,FA_size(1)+FAS_size(1)]);
                    end
                else
                    target_A_support = selected - FA_size(1);
                    if AunitS_health_list (target_A_support, 4) ~= 0
                        fflag=1;
                    else
                        selected = randi([1,FA_size(1)+FAS_size(1)]);
                    end
                end
            end
            if selected <= FA_size(1)
                target_A = selected;
                target_type = '普通';

                fprintf(['Rd',num2str(FA_size(1)),'=', num2str(target_A),'\n']);
                fprintf(['目标类型:', target_type, ' ',Aunit_name{target_A,1},' 被选为攻击目标\n']);
            else
                target_A_support = selected - FA_size(1);
                target_type = '支援';

                fprintf(['Rd',num2str(FAS_size(1)),'=', num2str(target_A_support),'\n']);
                fprintf(['目标类型:', target_type, ' ',AunitS_name{target_A_support,1},' 被选为攻击目标\n']);
            end
        end

        % 单位杀伤判定
        FB_damage = randi([0, Max_damge]);  % 这是随机生成的伤害

        fprintf('单位杀伤判定\n');
        fprintf(['Rd',num2str(Max_damge),'=', num2str(FB_damage),'\n']);

        % 杀伤效果评估(命中判定)
        hit = randi([0, 100]);
        fprintf('单位命中判定\n');
        fprintf(['Rd100','=', num2str(hit),'\n']);
        if hit >= 50
            hitFlag=1;
        end
        if hitFlag == 1
            %             FB_turn_damge = FB_turn_damge + FB_damage;
            %             % 更新伤害后的受损生命
            %             Aunit_health_list(target_A, 3) = Aunit_health_list(target_A, 3) - FB_damage;
            %             %fprintf([BunitS_name{i,1},' 攻击命中目标\n']);
            %             fprintf([Faction_name_misson{1,1},'的', Aunit_name{target_A,1}, '受到了', num2str(FB_damage), '点伤害\n\n']);
            %             % disp([Faction_name_misson(2,1), FB_unit_name(target_B,1), '受到了', num2str(FA_damage), '点伤害']);
            %
            %             % 单位损失判定
            %             % 判断是否有单位被消灭（生命值降为0或以下）
            %             % 暂时不考虑受损单位存在，直接判定被摧毁
            %             if Aunit_health_list(target_A, 3) <= 0
            %                 % disp(['阵营A的', FA_unit_name{target_A}, '被消灭!']);
            %                 fprintf([Faction_name_misson{1,1},'的', Aunit_name{target_A,1}, '被消灭！\n']);
            %                 Aunit_health_list(target_A, 6) = Aunit_health_list(target_A, 4);
            %                 Aunit_health_list(target_A, 4) = 0; % 单位存活状态更新
            %
            %             end

            % 根据目标类型更新伤害
            if strcmp(target_type, '普通')
                FB_turn_damge = FB_turn_damge + FB_damage;
                Aunit_health_list(target_A, 3) = Aunit_health_list(target_A, 3) - FB_damage;
                fprintf([Faction_name_misson{2,1},'的', Aunit_name{target_A,1}, '受到了', num2str(FB_damage), '点伤害\n\n']);
                % 普通单位摧毁判定
                if Aunit_health_list(target_A, 3) <= 0
                    fprintf([Faction_name_misson{2,1},'的', Aunit_name{target_A,1}, '被消灭！\n']);
                    Aunit_health_list(target_A, 6) = Aunit_health_list(target_A, 4);
                    Aunit_health_list(target_A, 4) = 0;
                end
            else
                AunitS_health_list(target_A_support, 3) = AunitS_health_list(target_A_support, 3) - FB_damage;
                fprintf([Faction_name_misson{2,1},'的支援单位', AunitS_name{target_A_support,1}, '受到了', num2str(FB_damage), '点伤害\n\n']);
                % 支援单位摧毁判定
                if AunitS_health_list(target_A_support, 3) <= 0
                    fprintf([Faction_name_misson{2,1},'的支援单位', AunitS_name{target_A_support,1}, '被消灭！\n']);
                    AunitS_health_list(target_A_support, 6) = AunitS_health_list(target_A_support, 4);
                    AunitS_health_list(target_A_support, 4) = 0;
                end
            end

%         else
%             fprintf([BunitS_name{i,1},' 攻击未命中\n\n']);
%         end
            % 敌方支援单位情况判定
            if  flagAS~=0 && sum(AunitS_health_list(:,4)) == 0
                fprintf([Faction_name_misson{1,1},'支援单位已全部损失\n']);
                flagAS=0;
            end
    
            % 胜利条件判断
            if sum(Aunit_health_list(:,4)) == 0
                fprintf([Faction_name_misson{1,1},'已无作战单位可用', Faction_name_misson{2,1}, '取得胜利\n']);
                FBwinFlag=1;
                break;
            end
    
        else
            fprintf([Faction_name_misson{2,1},' 攻击未命中\n\n']);
        end
    end
    % 目标选取
    % 杀伤效果评估
    % 回合结算，显示双方损失情况，并进行战斗力上限调整
    if FB_turn_damge ~= 0
        FA_health_power = FA_health_power - FB_turn_damge;
        fprintf(['由于战斗受损',Faction_name_misson{1,1},'战斗力下降至 ',num2str(FA_health_power),'\n']);
    end

    if FA_turn_damge ~= 0
        FB_health_power = FB_health_power - FA_turn_damge;
        fprintf(['由于战斗受损',Faction_name_misson{2,1},'战斗力下降至 ',num2str(FB_health_power),'\n']);
    end


    if FAwinFlag==1 || FB_health_power <=0
        disp('************************************************************')
        fprintf([Faction_name_misson{2,1},'已无作战单位可用', Faction_name_misson{1,1}, '取得胜利\n']);
        disp('************************************************************')
        break;
    elseif FBwinFlag==1 || FA_health_power <=0
        disp('************************************************************')
        fprintf([Faction_name_misson{1,1},'已无作战单位可用', Faction_name_misson{2,1}, '取得胜利\n']);
        disp('************************************************************')
        break;
    end

disp('++++++++++++++++++++++++++++++++');
disp(['第', num2str(turn), '回合结束']);
disp('++++++++++++++++++++++++++++++++');
end

% 战斗结算
% 暂时不考虑支援单位损失
for i = 1 : FA_size(1)
    if Aunit_health_list(i,3) < FA_unit_datalist(i,3) && Aunit_health_list(i,3) >0
        % 受损数量判定
        n_min = ceil((FA_unit_datalist(i,3)-Aunit_health_list(i,3))/FA_unit_datalist(i,2));
        Aunit_health_list(i,5) = randi([n_min,FA_unit_datalist(i,1)]);
        Aunit_health_list(i,4) = Aunit_health_list(i,4)-Aunit_health_list(i,5);
    end
end
for i = 1 : FB_size(1)
    if Bunit_health_list(i,3) < FB_unit_datalist(i,3) && Bunit_health_list(i,3) >0
        % 受损数量判定
        n_min = ceil((FB_unit_datalist(i,3)-Bunit_health_list(i,3))/FB_unit_datalist(i,2));
        Bunit_health_list(i,5) = randi([n_min,FB_unit_datalist(i,1)]);
        Bunit_health_list(i,4) = Bunit_health_list(i,4)-Bunit_health_list(i,5);
    end
end

% 损伤报告
FA_unit_lost_report = table('Size',[FA_size(1)+FAS_size(1),5], ...
    'VariableTypes',{'string','double','double','double','double'}, ...
    'VariableNames',{'单位名称', '参战单位总数', '完好', '受损', '损失'});
FB_unit_lost_report = table('Size',[FB_size(1)+FBS_size(1),5], ...
    'VariableTypes',{'string','double','double','double','double'}, ...
    'VariableNames',{'单位名称', '参战单位总数', '完好', '受损', '损失'});

FA_unit_lost_report(1:FA_size(1),1)=FA_unit_name;
FA_unit_lost_report(FA_size(1)+1:FA_size(1)+FAS_size(1),1)=FA_unitS_name;
FA_unit_lost_report(1:FA_size(1),2)=array2table(FA_unit_datalist(:,1));
FA_unit_lost_report(FA_size(1)+1:FA_size(1)+FAS_size(1),2)=array2table(FA_unitS_datalist(:,1));
FA_unit_lost_report(1:FA_size(1),3:5)=array2table(Aunit_health_list(:,4:6));
FA_unit_lost_report(FA_size(1)+1:FA_size(1)+FAS_size(1),3:5)=array2table(AunitS_health_list(:,4:6));

FB_unit_lost_report(1:FB_size(1),1)=FB_unit_name;
FB_unit_lost_report(FB_size(1)+1:FB_size(1)+FBS_size(1),1)=FB_unitS_name;
FB_unit_lost_report(1:FB_size(1),2)=array2table(FB_unit_datalist(:,1));
FB_unit_lost_report(FB_size(1)+1:FB_size(1)+FBS_size(1),2)=array2table(FB_unitS_datalist(:,1));
FB_unit_lost_report(1:FB_size(1),3:5)=array2table(Bunit_health_list(:,4:6));
FB_unit_lost_report(FB_size(1)+1:FB_size(1)+FBS_size(1),3:5)=array2table(BunitS_health_list(:,4:6));

% 将损失报告存为Excel文件
writetable(FA_unit_lost_report, 'FA_unit_lost_report.xlsx');
writetable(FB_unit_lost_report, 'FB_unit_lost_report.xlsx');
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
disp('损失报告')
fprintf([Faction_name_misson{1,1},'\n']);
disp(FA_unit_lost_report);
fprintf([Faction_name_misson{2,1},'\n']);
disp(FB_unit_lost_report);