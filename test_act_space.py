import gym
import minerl

def check_action_space(env_name):
    print("==================================")
    print("Task name:", env_name)
    env = gym.make(env_name)

    action = env.action_space.no_op()
    print(type(action))

    print("Types of the action space:", env.action_space)
    print("\nDetails about the action space:")

    for action_name, action_subspace in env.action_space.spaces.items():
        print(f"- {action_name}: {action_subspace}")

    print("==================================")


check_action_space("MineRLNavigateDense-v0")
check_action_space("MineRLObtainDiamondShovel-v0")

