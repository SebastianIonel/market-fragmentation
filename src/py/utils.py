import pykx as kx
q_script_path = "./src/q/app.q"

def start_up():
    # load q script
    kx.q(f'\\l {q_script_path}')
    print("Q script loaded successfully.")

# def get_interval_data(filter_rule="OB", multi_market="none"):
    
    

def test():
    with open('example.txt', 'w') as file:
        file.write("Hello, world!\n")
        file.write("This is a new line.\n")
    
    return "Hello from FastAPI"

