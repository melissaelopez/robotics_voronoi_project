%{
	Environment class
	
		The environment object defines an instance of the
		path planning problem for a disc robot.
		It needs these data (i.e., properties):
		 
				-- radius of robot
				-- epsilon
				-- bounding box for obstacles
				-- start and goal config of robot
				-- obstacle set (set of polygons)
	
		An environment file (e.g., env0.txt) is a line-based text file
		containing the above information, in THIS STRICT ORDER.
		Comment character (%) indicates that the rest of a line
		are ignored.
	
		Methods:
			showEnv( obj, fname )	-- IMPLEMENTED FOR YOU.
			readFile( obj, fname )
			test( obj, fname )

			showDisc( obj, a, b, c )
			showBoundingBox( obj )
			outputFile( obj, fname )

		HINT: try to provide default arguments for most methods
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	Intro to Robotics, Spring 2017
	%	Chee Yap (with help of TAs Naman and Rohit)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

classdef EnvironmentML < handle
     properties
        radius;
        epsilon;
        BoundingBox = {};
        start = [];
        goal = [];
        Polygons = {};
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% readFile( obj, fname )
	%	-- Reads an "env.txt" file with lines in this order:
	%	     radius, eps, BBX, BBY, start, goal, {PX,PY}*
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = readFile(obj, filename) %fills all the properties
        % Get the fileID so we can read the file line by line
        fileID = fopen(filename,'r');
        
        % Create an infinite loop that'll be broken once we've seen each
        % line of the file
        while 1
            line = fgetl(fileID);
            if (line == -1) % fgetl returns -1 when there's nothing there
                break;   
            % Read radius info
            elseif strncmpi(line, 'radius:', 3)
                r = str2double(line(9:end));
            %Read epsilon info
            elseif strncmpi(line, 'epsilon:', 3)
                eps = str2double(line(10:end));
            % Read bounding box info
            elseif strncmpi(line, '%Bounding', 5)
                xLine = fgetl(fileID);
                yLine = fgetl(fileID);
                BBX = str2num(xLine(5:end));
                BBY = str2num(yLine(5:end));
                bb = {BBX BBY};
             % Read configuration info
             elseif strncmpi(line, '%Configurations', 5)
                sLine = fgetl(fileID);
                if (strncmpi(sLine, '%start', 5))
                    sLine = fgetl(fileID);
                end
                gLine = fgetl(fileID);
                start = str2num(sLine(9:end));
                goal = str2num(gLine(6:end));
            % Setup framework for reading each polygon
            elseif strncmpi(line, '% What follows is', 10)
                % Setup outter while-loop for unknown number of polygons to
                % read info for from the file
                while 1
                    if (line == -1)
                        break;
                    else
                        % Get lines by info patterns in the file
                        line = fgetl(fileID); % blank line
                        line = fgetl(fileID); % shape name
                        xLinex = fgetl(fileID);
                        yLiney = fgetl(fileID);
                        disp(xLinex);
                        disp(yLiney);
                        % Check to see if reader ran into an extra comment
                        % line unexpectedly!
                        if (strncmpi(yLiney, '%P', 2))
                            % Reader will try to get the next two lines
                            % since the first time it ran into comments
                            xLinex = fgetl(fileID);
                            yLiney = fgetl(fileID);
                        end
                        
                        if (strncmpi(xLinex, '% END', 5))
                            break;
                        elseif (strncmpi(yLiney, '% END', 5))
                            break;
                        elseif (xLinex == -1)
                            break;    
                        elseif (yLiney == -1)
                            break;    
                        end
                        kx = strfind(xLinex, '%');
                        ky = strfind(yLiney, '%');
                        if length(kx) > 0
                            newEnd = kx(1);
                            x = str2num(xLinex(5:newEnd-1));
                        else
                            x = str2num(xLinex(5:end));
                        end
                        if length(ky) > 0
                            newEnd = ky(1);
                            y = str2num(yLiney(5:newEnd-1));
                        else
                            y = str2num(yLiney(5:end));
                        end
                        
                        obj.Polygons{end+1} = {x y};
                    end
                end
              
            end
        end
        obj.radius = r;
        obj.epsilon = eps;
        obj.BoundingBox = bb;
        obj.start = start;
        obj.goal = goal;
    end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 % Display Robot at conf(a,b) with color c 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function showDisc(obj,a,b,c)
        disp(obj);
        t = linspace(0, 2*pi);
        r = obj.radius;
        x = r*cos(t) + a;
        y = r*sin(t) + b;
        patch(x, y, c)
        axis square
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 % Display Bounding Box 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function showBoundingBox(obj)
        x = obj.BoundingBox{1};
        y = obj.BoundingBox{2};
        v = [x(1) y(1); x(2) y(2); x(3) y(3); x(4) y(4)];
        f = [1 2 3 4];
        patch('Faces', f,...
            'Vertices', v,...
            'EdgeColor','blue',....
            'FaceColor', 'none',....
            'LineWidth', 3);
    end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 % Output Image to file 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function outputFile(obj, fname)
            if nargin<2
                fname = 'image.jpg';
            end
            axis square tight;
            alpha(0.3);	% DOES NOT WORK for screen? OK for image...
            F = getframe(gca);
            imwrite(F.cdata,fname);
            
            % EXPERIMENTAL:
            J = imresize(F.cdata, [256 256]);
            imwrite(J,'image_resized.jpg');
        end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 % Display Environment:
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  function obj = showEnv(obj)
	     figure(1);
	     clf(1);  % clear fig 1
	      axis square tight;
	      alpha(0.3);	% Transparency (to show overlaps)
	     % Show Bounding Box:
	     obj.showBoundingBox();
	     % show start and goal config:
	     bluegreen=[0, 1, 1];
	     redgreen=[1, 1, 0];
	     obj.showDisc(obj.start(1), obj.start(2), bluegreen);
	     obj.showDisc(obj.goal(1), obj.goal(2), redgreen);
	
	      %Display the obstacles in brown:
	      brown = [0.8, 0.5, 0];
          
	      for C = obj.Polygons
              x = cell2mat(C{1}(:,1));
              y = cell2mat(C{1}(:,2));
%               disp(x);
%               disp(y);
	          patch(x,y, brown)
              alpha(0.3)
          end
	      
	         %
            F = getframe(gca);
            imwrite(F.cdata,'fig1.jpg');
            
            
            % Output an image file:
            obj.outputFile('image.jpg');
         end
     end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Static)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function a = test( filename )
	    if nargin<1
		filename = 'env0.txt';
	    end
            a = EnvironmentML;
            a = readFile(a, filename);
            ...disp(a.BoundingBox);
            
            bluegreen=[0, 1, 1];
             redgreen=[1, 1, 0];
             a.showDisc(a.start(1), a.start(2), bluegreen);
             a.showDisc(a.goal(1), a.goal(2), redgreen);
	
          showEnv(a); % show the entire environment
% 
% 	    % ADDITIONAL TEST: show obstacles using "mapshow" instead of 
% 	    %		patch.  How to do color?
% 	    figure(2);
% 	    clf(2);
% 	    axis tight square;
% 	    alpha(0.3);
% 	    a.showBBox();
%             % shape = mapshape(a.X_bag, a.Y_bag);
%             % mapshow(shape.X,shape.Y,...
% 	    % 	'DisplayType','polygon',...
% 	    % 	'FaceColor', [0.8, 0.5, 0]...   % brown
% 	    % 	); 
        end
    end
end
