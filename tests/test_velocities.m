%% Main function to generate tests
function tests = test_velocities
tests = functiontests(localfunctions);
end

%% Test Functions
function test_vint2vrms(self)
    
    VRMS = [1, 1, sqrt(2), 2]' * 1000;
    TWT = [0; 2; 3; 3.5];
    vint = [1000; 2000; 4000];
    depths = [0; 1000; 2000; 3000];
    
    
    [vrms, twt] = velocities.vint2vrms(vint, depths);
    assert(all(vrms == VRMS))
    assert(all(twt == TWT))
    
    % test autofill of depths values
    [vrms, twt] = velocities.vint2vrms(vint, depths(1:end-1));
    assert(all(vrms == VRMS))
    assert(all(twt == TWT))
end
