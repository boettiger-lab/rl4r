


step_fn <- function(self, action) {

    p <- self$config$parameters

    #' 'state' space should be in (-1, 1)
    X <- (self$state + 1) / 2

    # 'action' space should be in (-1, 1)
    h <- (action + 1 ) / 2
    
    # Reward
    reward <-  h * (h < X)  #pmin(h, X) # cannot harvest more than all X fish

    # Harvest
    X <- (X - h) * (h <= X)

    # Recruit
    X <- X + p$r * X * (1 - X / p$k) + p$sigma_x * X * rnorm(1, 0)

    # Advance time counter
    self$time <- self$time + 1

    # Game-over conditions
    truncated <- FALSE
    terminated <- FALSE
#    if (X <= 0 ) {
#        truncated <- TRUE
#    }
#    if (self$time <= self$config$Tmax) {
#        terminated <- TRUE
#    }

    # 'state' space should be in (-1, 1)
    self$state <- 2 * X - 1

    # RL agent observes in the raw state space
    observation <- self$state

    # catch-all place to provide additional information to user/other functions
    info = list()

    # must have this return type
    list(observation, reward, terminated, truncated, info)
}

reset_fn <- function(self, seed = NULL, options = NULL) {
    
    self$time <- 0
    self$state <- self$config$init_state
    observation <- self$state
    info <- list()

    # As an R function this doesn't modify 'self'
    # self <<- self

    # must have this return
    list(observation, info)
}

parameters <- list(r = 0.1, k = 1, sigma_x = 0.01)
config <- list(Tmax = 100, parameters = parameters, init_state = 0)
self <- list(time = 0, state = config$init_state, config = config)

step_fn(self, -1)


reticulate::py_require(c("gymnasium", "numpy"))
gym <- reticulate::import("gymnasium")
np <- reticulate::import("numpy")


action_space <- gym$spaces$Box(low = -1, high = 1, dtype = np$float32)
observation_space <- gym$spaces$Box(low = -1, high = 1, dtype = np$float32)

classes <- reticulate::py_run_file("inst/python/basic_class.py")
fish <- classes$CustomEnv(action_space = action_space,
                          observation_space= observation_space,
                          step_fn = reticulate::r_to_py(step_fn),
                          reset_fn = reticulate::r_to_py(reset_fn),
                          config = config)

fish$reset()
fish$step(-1)

reticulate::py_require("sb3-contrib")
