import pykx as kx
q_script_path = "./src/q/app.q"

def start_up():
    # load q script
    kx.q(f'\\l {q_script_path}')

def get_interval_data(filter_rule="OB", multi_market="none"):
    result = kx.q(f'getIntervalData buildParams[`{filter_rule};`{multi_market}]').py()
    return result
    

def test():
    res = get_interval_data("TM", "none")
    return f"a is: {res}"

