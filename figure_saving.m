function figure_saving( varargin )
%figure_saving(file_name,format)
    % Normalises the figure that I am plotting, goes through plots and
    % makes them nice.
    %
    %Options for format are fig, pdf (best), eps (always done in colour), png 
    %(300dpi, >300 changes some random variables) or matlab2tikz.
    %
    %If format is left blank the a .fig file will be saved as standard. If
    %there is no inputs passed to figure_saving() then the plot will be
    %normalised and nothing else will happen.

    %% Variables used throughout
    font_size = 11; %font size in points
    width = 3.5; %width in inches
    %% Start
    objects = findall(gcf);
    
    obj_rem = {'uiMenu'
        'uiPushTool'
        'uiToggleTool'
        'uiToggleSplitTool'
        'uiToolbar'
        'Figure'
        };
    
    rem_mat = zeros(length(objects),1);
    
    legend_object = false;
    colorbar_object = false;
    for n = 1:length(objects)
        for m = 1:length(obj_rem)
            if strcmpi(objects(n).Type,'legend')
                legend_object = true;
            elseif strcmpi(objects(n).Type,'colorbar')
                colorbar_object = true;
            elseif strcmpi(objects(n).Type,'axes')
                if ~strcmpi(objects(n).Title,'')
                    main_parent = objects(n);
                end
            elseif strcmpi(objects(n).Type,obj_rem{m})
                rem_mat(n) = 1;
                break
            end
        end
    end
    
    objects(logical(rem_mat)) = [];
    %% Changing the things to make it look nice depending on the type (text, legend, etc.)
    n = 1;
    while n <= length(objects)
        if strcmpi(objects(n).Type,'text') || strcmpi(objects(n).Type,'textboxshape')
            set(objects(n),'Interpreter','LaTeX',...
                'FontSize',font_size,...
                'FontName','LaTeX')
        elseif strcmpi(objects(n).Type,'legend')
            set(objects(n),'Interpreter','LaTeX',...
                'FontSize',font_size,...
                'FontName','LaTeX')
        elseif strcmpi(objects(n).Type,'colorbar')
            if isempty(get(objects(n),'ylabel')) && isempty(get(objects(n),'xlabel')) && isempty(get(objects(n),'title'))
                set(objects(n),'TickLabelInterpreter','LaTeX',...
                    'FontSize',font_size,...
                    'FontName','LaTeX',...
                    'LineWidth',1)
            else
                if ~isempty(get(objects(n),'ylabel'))
                    %                     colorbar_label = get(get(objects(n),'ylabel'),'String');
                    set(get(objects(n),'ylabel'),'Interpreter','LaTeX',...
                        'FontSize',font_size,...
                        'FontName','LaTeX')
                end
                if ~isempty(get(objects(n),'xlabel'))
%                     colorbar_label = get(get(objects(n),'xlabel'),'String');
                    set(get(objects(n),'xlabel'),'Interpreter','LaTeX',...
                        'FontSize',font_size,...
                        'FontName','LaTeX')
                end
                if ~isempty(get(objects(n),'title'))
%                     colorbar_label = get(get(objects(n),'title'),'String');
                    set(get(objects(n),'title'),'Interpreter','LaTeX',...
                        'FontSize',font_size,...
                        'FontName','LaTeX')
                end
%                 colorbar_label = strcat('\makebox[3in][c]{',colorbar_label,'}');
                set(objects(n),'TickLabelInterpreter','LaTeX',...
                    'FontSize',font_size,...
                    'FontName','LaTeX',...
                    'LineWidth',1)
%                 colorbar_position = get(objects(n),'Position');
%                 objects(end+1) = annotation('textbox',...
%                     [colorbar_position(1)-0.01 colorbar_position(2) 0.01 colorbar_position(4)],...
%                     'String',colorbar_label,...
%                     'LineStyle','none',...
%                     'HorizontalAlignment','Right');
            end
            
            if strcmpi(objects(n).Location,get(groot,'DefaultColorbarLocation'))
                set(objects(n),'Location','southoutside')
            end
        elseif strcmpi(objects(n).Type,'line')
            if objects(n).LineWidth == get(groot,'DefaultLineLineWidth') && objects(n).MarkerSize == get(groot,'DefaultLineMarkerSize')
                set(objects(n),...
                    'LineWidth',2,...
                    'MarkerSize',10)
            end
        elseif strcmpi(objects(n).Type,'axes')
            set(objects(n),'TickLabelInterpreter','LaTex',...
                'Box','on',...
                'FontSize',font_size,...
                'LineWidth',1,...
                'Color',[1 1 1],...
                'XLim',get(objects(n),'XLim'),...
                'YLim',get(objects(n),'YLim'))
        elseif strcmpi(objects(n).Type,'contour')
            set(objects(n),'LineWidth',1)
        elseif strcmpi(objects(n).Tag,'CONTOURCMAP')
            parent_axes = objects(n).Parent; %finding the parent axes of the contourcmap
            set(parent_axes,'XTickLabelRotation',90) %rotating the tick labels 90deg to make them readable
            parent_position = get(parent_axes,'OuterPosition');
            main_position = get(main_parent,'OuterPosition');
            new_position = main_position;
            new_position(2) = parent_position(2) + parent_position(4);
            new_position(4) = main_position(4) - (new_position(2) - main_position(2));
            set(main_parent,'OuterPosition',new_position)
        end
        
        n = n + 1;
    end
    
        %% Changing things to make it look pretty regardless of plot type
    
    %If the paper position is default (or within {\pm}1%), it changes it, if it is not then it
    %does not and will apply the appropriate paper positions and sizes.
    
    if (sum(0.95*get(groot,'DefaultFigurePosition') <= get(gcf,'Position')) == 4) && (sum((get(gcf,'Position') <= 1.05*get(groot,'DefaultFigurePosition'))) == 4)
        set(gcf,'Units','inches')
        if legend_object == false && colorbar_object == false
            set(gcf,'Position',[5,5,width,0.9*width])
        else
            set(gcf,'Position',[5,5,width,width])
        end
    else
        set(gcf,'Units','inches')        
    end
    
    pos = get(gcf,'Position');
    set(gcf,'PaperUnits','inches',...
        'PaperPosition',[0,0,pos(3),pos(4)],...
        'PaperSize',[pos(3),pos(4)],...
        'InvertHardcopy','off',...
        'Color',[1 1 1])
        
    %% Saving it out
    drawnow
    if length(varargin) >= 1
        if length(varargin) == 1 || strcmpi(varargin{2},'fig')
            savefig(varargin{1})
        elseif strcmpi(varargin{2},'matlab2tikz')
            cleanfigure
            additional_axis_opt = {'width=\columnwidth,'
                'at={(0\columnwidth,0\columnwidth)},'
                };
            warning('off','all')
            matlab2tikz(strcat(varargin{1},'.tex'),'strict',true,...
                'width','\columnwidth','showInfo',false,...
                'noSize',true,'extraAxisOptions',additional_axis_opt)
            warning('on','all')
            warning('Legend in TiKz has unpredictable behaviour, will require manual edit')
        elseif strcmpi(varargin{2},'pdf')
            print(varargin{1},'-dpdf','-painters')
        elseif strcmpi(varargin{2},'eps')
            print(varargin{1},'-depsc','-tiff')
        elseif strcmpi(varargin{2},'png')
            if length(varargin) == 2
                print(varargin{1},'-dpng','-r300')
                warning('Saved at 300dpi as standard, use ''-rX'' in position 3 where ''X'' is the resultion to alter this')
            else
                print(varargin{1},'-dpng',varargin{3})
            end
        end
    end
end

