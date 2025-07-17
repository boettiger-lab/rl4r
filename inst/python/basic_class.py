
import gymnasium as gym

class CustomEnv(gym.Env):
    def __init__(self, 
                 action_space, 
                 observation_space, 
                 step_fn, 
                 reset_fn, 
                 config):
        super().__init__()

        self.reset_fn = reset_fn
        self.step_fn = step_fn
        self.config = config
        
        self.action_space = action_space
        self.observation_space = observation_space
        self.reset()

    def step(self, action):
        out = self.step_fn(self, action)
        return out[0], out[1], out[2], out[3], out[4]

    def reset(self, seed=None, options=None):
        out = self.reset_fn(self, seed, options)
        return out[0], out[1]
