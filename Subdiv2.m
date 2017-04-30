%{
WARNING: it is VERY rough, and probably wrong!

	Subdiv2
		-- derived from Subdiv1
        -- we compute adjancies for box2 objects

%}
classdef Subdiv2 < Subdiv1 %& Geom2d
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        env;        % environment
        unionF;     % union find data structure
    end
    
    properties ( Access = private)
        %white = [1 1 1]
        %gray = [0.5 0.5 0.5]
        %red = [1 0 0]
        %yellow = [1 1 0]
        %green =[0 1 0]
        colo = [[1 1 1];[0.5 0.5 0.5];[1 0 0]; [1 1 0]; [0 1 0]];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Constructor for Subdiv2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Subdiv2(x, y, w, Polygons)
            % Constructor for Subdiv
            obj = obj@Subdiv1(x, y, w);
            % Set rootbox features and classify it.
            obj.rootBox.features = Polygons;
            obj.rootBox.classification = BoxType.MIXED;
        end
        
        %	THIS IS A KEY METHOD:
        %		It is best to call sub-methods.
        %
        %         function child = split(obj)
        %		1. call Box2.split
        %		2. For each child:
        %			2.1 compute its features
        %			2.2 classify the child
        %			2.3 if FREE, add child to UnionFind structure
        %		3. For each child:
        %			If it is FREE, do UNION with all its neighbors
        %			%	NOTE that this is NOT done as step 2.4! Why?
        %         end
        
        % Split(box)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function split(obj, box)
            box.split();
            %             for i_dash = Idx.children()
            %                     i = Idx.quad(i_dash);
            %                     obj.updateFeatures(box.child(i));
            %                     %obj.classify(box.child(i));
            %                     if (box.child(i).type == BoxType.FREE)
            %                         obj.unionF.add(box.child(i));
            %                     end %if
            %             end %for
            %
            for i_dash = Idx.children()
                i = Idx.quad(i_dash);
                    box.child(i).pNbr = [Box2.null Box2.null Box2.null Box2.null];
                for j_dash = Idx.dirs()
                    k = Idx.quad(Idx.nbr(i_dash,j_dash));
                    j = Idx.dir(j_dash);
                    if(Idx.isSibling(i_dash,j_dash))
                        box.child(i).pNbr(j) = box.child(k);
                    else
                        if(box.pNbr(j).isLeaf)
                            box.child(i).pNbr(j) = box.pNbr(j);
                        else
                            box.child(i).pNbr(j) = box.pNbr(j).child(k);
                        end
                    end
                end
            end %for
        end %split
        
        function neighbour = getNeighbours(obj,box)
            dir = Idx.dirs();
            neighbour = [obj.getNbrDir(box,dir(1))...
                obj.getNbrDir(box,dir(2))...
                obj.getNbrDir(box,dir(3))...
                obj.getNbrDir(box,dir(4))];
        end
        
        function nbrs = getNbrDir(obj,box,dir_dash)
            pN = box.pNbr(Idx.dir(dir_dash));
            if(pN.isLeaf)
                nbrs = [pN];
            else
                nbrs = obj.getLeavesDir(pN,dir_dash);
            end
        end
        
        function lvs = getLeavesDir(obj,box,dir_dash)
            if(box.isLeaf)
                lvs = [box];
            else
                dd = Idx.adj(dir_dash);
                lvs = [obj.getLeavesDir(box.child(Idx.quad(dd(1))),dir_dash)...
                    obj.getLeavesDir(box.child(Idx.quad(dd(2))),dir_dash)];
            end
        end
        
        function updateFeatures(~,~)
        end
        
        %{
function classify(obj,box)
            random = rand(1);
            if(random > 0.6)
                box.type = BoxType.FREE;
            elseif(random < 0.3)
                box.type = BoxType.STUCK;
            else
                box.type = BoxType.MIXED;
            end
        end
        %}
        function plotLeaf(obj,box, type)
            if nargin < 2
                box = obj.rootBox;
            end
            if nargin < 3
                type = BoxType.UNKOWN;
            end
            %plot(box.shape().X,box.shape().Y,'b-');
            hold on;
            obj.plotLeaves(box,type);
            hold off;
        end
        
        function plotLeaves(obj, box, type)
            if(box.isLeaf && (box.type == type || type == BoxType.UNKOWN))
                fill(box.shape().X,box.shape().Y,obj.colo(box.type + 4,:));
                plot(box.shape().X,box.shape().Y,'b-');
            else
                for i = 1:length(box.child)
                    obj.plotLeaves(box.child(i),type);
                end
            end
            xlim([obj.rootBox.x - obj.rootBox.w, obj.rootBox.x + obj.rootBox.w]);
            ylim([obj.rootBox.y - obj.rootBox.w, obj.rootBox.y + obj.rootBox.w]);
        end
        
        function plotNbrs(obj, box, nbrsList, dir)
            if nargin < 3
                box = obj.rootBox;
            end
            if nargin < 4
                dir = 0;
            end
            hold on;
            fill(box.shape().X,box.shape().Y,[0 1 0]);
            plot(box.shape().X,box.shape().Y,'b-');
            
            for i = 1:length(nbrsList)
                if(nbrsList(i) ~= Box2.null && (dir == 0))% dirs to be implemented
                    %Direction code incorrect needs fixing
                    fill(nbrsList(i).shape().X,nbrsList(i).shape().Y,[1 1 0]);
                    plot(nbrsList(i).shape().X,nbrsList(i).shape().Y,'b-');
                end
            end
            
            xlim([obj.rootBox.x - obj.rootBox.w, obj.rootBox.x + obj.rootBox.w]);
            ylim([obj.rootBox.y - obj.rootBox.w, obj.rootBox.y + obj.rootBox.w]);
            hold off;
        end
    end
    
    methods (Static = true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test()
            fname = 'env0.txt';
            s = Subdiv2(fname);
            
            %%%%%%%%%%%%%%%%%%%%%% FIRST SPLIT:
            rootBox = s.rootBox;
            s.split(rootBox);
            %rootBox.showBox();
            
            %%%%%%%%%%%%%%%%%%%%%% SECOND SPLIT:
            box = s.findBox(9,1);
            s.split(box);
            
            %%%%%%%%%%%%%%%%%%%%%% THIRD SPLIT:
            box = s.findBox(9,1);
            s.split(box);
            
            box = s.findBox(8.125,0.625);
            s.split(box);
            
            %box = s.findBox(2.5,2.5);
            box = s.findBox(8.13,1.9);
            nbrs = s.getNeighbours(box);
            s.plotNbrs(box,nbrs); % Assuming 1-N, 2-W, 3-S, 4-E, dir needs to be impemented
            %s.showSubdiv();
            %s.displaySubDiv();
            %s.plotLeaf(rootBox, BoxType.MIXED);
        end
    end
end
