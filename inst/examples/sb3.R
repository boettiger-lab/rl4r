
library(reticulate)
py_require("numpy")
py_require("gymnasium[classic_control]")
np <- import("numpy")
gym <- import("gymnasium")

py_require("stable-baselines3")
sb3 <- import("stable_baselines3")

make_vec_env <- sb3$common$env_util$make_vec_env


vec_env = make_vec_env("CartPole-v1", n_envs=as.integer(4))
model = sb3$PPO("MlpPolicy", vec_env)
model$learn(total_timesteps=as.integer(25000))
model$save("ppo_cartpole")


## Try a harder model, better with GPU

reticulate::py_require("sb3-contrib")
sb3_contrib <- reticulate::import("sb3_contrib")

TQC <- sb3_contrib$TQC
env <- gym$make("Pendulum-v1", render_mode="human")
policy_kwargs <- list(n_critics=2L, n_quantiles=25L)
model <- TQC("MlpPolicy", env, top_quantiles_to_drop_per_net=2L, verbose=1L, policy_kwargs=policy_kwargs)
model$learn(total_timesteps=10000L, log_interval=4L)

model$save("tqc_pendulum")
model = TQC$load("tqc_pendulum")

r = env$reset()
obs = r[[1]]

for i in range(0,10):
    m = model$predict(obs, deterministic=TRUE)
    action = m[[1]]
    s = env$step(action)

    # R can't unpack multiple-return objects
    state = s[[1]]
    reward = s[[2]]
    terminated = s[[3]]
    truncated = s[[4]]
    env$render()
    if(terminated || truncated) {
      obs, _ = env$reset()
    }
