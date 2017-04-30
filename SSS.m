%{
	SSS class:
		this is the main class encoding the
		"Soft Subdivision Search" technique.

	The Main Method:
		Setup Environment
			(read from file and initialize data structures)
%}

classdef SSS < handle

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		fname;		% filename
		sdiv;		% subdivision
        env;
        unionF;
		path=[];	% path 
		startbox=[];% box containing the start config
		goalbox=[];	% box containing the goal config
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % Constructor
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function sss = SSS(fname)
	    	if (nargin < 1)
                fname = 'env0.txt';
            end
            sss.setup(fname);
	    end

	    


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % mainLoop
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = mainLoop(obj)

	        flag = false;
	    	obj.startBox = obj.makeFree(startConfig);
		if isempty(startBox)
		    obj.display('NOPATH: start is not free');
		    return;
		end

	    	obj.goalBox = obj.makeFree(goalConfig);
		if isempty(goalBox)
		    display('NOPATH: goal is not free');
		    return;
		end

		if (~obj.makeConnected(obj.startBox, obj.goalBox))
		    display('NOPATH: start and goal not connected');
		    return;
		end
		flag = true;
	    end


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % Setup
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function setup(obj, fname)
%             obj.env = Environment;
%             obj.env = obj.env.readFile(fname);
%             obj.sdiv = Subdiv2(obj.env.rootbox.x,...
%             obj.env.rootbox.y,...
%             obj.env.rootbox.w);	
%             obj.unionF = UnionFind();
            
            obj.env = Environment;
            obj.env = obj.env.readFile(fname);
            [xx, yy, ww] = obj.getBoxParameters(obj.env.BoundingBox);
            obj.sdiv = Subdiv2(xx, yy, ww, obj.env.Polygons);
            obj.unionF = UnionFind();
        end
        
        % ADDED*****
        % returns the box parameters for the bounding box.
        % NEEDS to be updated to change the calculations
        % for mid1 and mid2.
        function [xx, yy, ww] = getBoxParameters(obj, bound)
            % Compute boundBox centerpoint, assuming that
            % it is always a square.
            mid1 = 5; % TODO change this to calculations
            mid2 = 5;
            % Make sure we get the orientation right.
            if bound.x(2) == bound.x(1)
                xx = mid2;
                yy = mid1;
                ww = abs(bound.y(1) - bound.y(2))/2;
            else
                xx = mid1;
                yy = mid2;
                ww = abs(bound.x(1) - bound.x(2))/2;
            end
        end


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % makeFree(config)
	    %		keeps splitting until we find
	    %		a FREE box containing the config.
	    %		If we fail, we return [] (empty array)
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function box = makeFree(config)
            while 1
                
            end
	    end


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % makeConnected(startBox, goalBox)
	    %		keeps splitting until we find
	    %		a FREE path from startBox to goalBox.
	    %		Returns true if path found, else false.
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = makeConnected(startBox, goalBox)
	    end

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % showPath(path)
	    %		Animation of the path
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function showPath(path)
	    end

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % showEnv()
	    %		Display the environment
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function showEnv()
            obj.env.showEnv();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % run (arg)
	    %		if no arg, run default example
	    %		if with arg, do
	    %			interactive loop (ignores arg)
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function run(obj, arg)
        if nargin<1
			obj.mainLoop();
			obj.showPath();
			return;
        end

		fprintf('\n*******************************\n       Welcome to SSS!\n*******************************\n\n');
		while true
			option = input(...
				['Select An Option:\n',...
				'0 = quit\n1 = mainLoop\n2 = showEnv\n3 = showPath\n',...
				'4 = new setup\n---> ']);
	          switch option
		    case 0,
			return;
		    case 1,
			obj.mainLoop();
			obj.showPath();
		    case 2,
			obj.env.showEnv();
		    case 3,
			obj.showPath();
		    case 4,
			obj.fname=input('input environment file');
			obj.setup(obj.fname);
			obj.showEnv();
		    otherwise
			disp('invalid option');
	          end % switch
	        end % while
	    end

	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static = true)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % test()
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = test(filename)
            if nargin < 1
                filename = 'env0.txt';
            end
            obj = SSS(filename);
            obj.run(filename);
        end

	end


end % SSS class

