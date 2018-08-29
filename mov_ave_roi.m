function [ qty_output ] = mov_ave_roi( Val, buy_logic, init_shares, init_money, max_shares )
 qty_1 = init_shares; %shares
                qty_2 = init_money; %money
                share_max = max_shares;
                init_output = qty_1*Val(1);
                
                for n = 1:length(buy_logic)
                    if buy_logic(n) && qty_1 >= share_max %checkin the logic and making sure there isn't more sold than is owned
                        if share_max > qty_1
                            qty_2 = qty_2 + round((share_max*Val(n))*100)/100;
                            qty_1 = qty_1 - share_max;
                        else
                            share_qty = qty_1;
                            qty_2 = qty_2 + round((share_qty*Val(n))*100)/100;
                            qty_1 = qty_1 - share_qty;
                        end
                    elseif ~buy_logic(n)
                        if qty_2-(share_max*Val(n)) >= 0
                            qty_1 = qty_1 + share_max; %floor(qty_2/Val(n));
                            qty_2 = qty_2-(share_max*Val(n));
                        else
                            share_qty = floor(qty_2/Val(n));
                            qty_1 = qty_1 + share_qty;
                            qty_2 = qty_2-(share_qty*Val(n));
                        end
                    end
                end
                
                qty_output = 260*(((qty_2 + round((qty_1*Val(end))*100)/100)/init_output)/length(Val));
            
end

