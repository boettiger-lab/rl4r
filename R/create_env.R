

dummy <- function() {

devtools::load_all()

reticulate::py_require(c("gymnasium", "numpy"))

custom_class <- system.file("python/class.py", package = 'rl4r', mustWork = TRUE)
custom_class <- "inst/python/class.py"
classes <- reticulate::py_run_file(custom_class)

fish <- classes$fish()
fish$step(0)
fish$parameters


### customize parameters:
parameters = list(
r_x = 0.01,
K = 1,
sigma_x = 0.05,
q_0 = 0.1,
price = 9
)

utility <- function(pop, effort, p) {
    # be careful about indexing
   effort * pop * p["price"] + rnorm(1,0,.1)
   return(-10)
}

fish2 <- classes$fish(config = list(parameters = parameters, 
                                    utility = reticulate::r_to_py(utility)
                                    )
                     )
fish2$step(0)



# use stable-baselines3:
reticulate::py_require("stable-baselines3")
sb3 <- reticulate::import("stable_baselines3")
status <- sb3$common$env_checker$check_env(fish)




}

