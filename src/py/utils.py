import pykx as kx
q_script_path = "./src/q/app.q"

def start_up():
    # load q script
    kx.q(f'\\l {q_script_path}')

def get_interval_data(filter_rule="OB", multi_market="none"):
    # check if params are valid
    if filter_rule not in ["OB", "TM", "DRK"]:
        raise ValueError("Invalid filter_rule. Choose from 'OB', 'TM', or 'DRK'.")
    if multi_market not in ["none", "all", "TM", "OB", "DRK"]:
        raise ValueError("Invalid multi_market. Choose from 'none' or 'all'.")
    result = kx.q(f'getIntervalData buildParams[`{filter_rule};`{multi_market}]').py()
    return result
    

def test():
    res = get_interval_data("TM", "none")
    return f"a is: {res}"

