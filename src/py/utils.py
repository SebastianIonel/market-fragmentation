import pykx as kx
import pandas as pd
q_script_path = "./src/q/app.q"

def start_up():
    # load q script
    kx.q(f'\\l {q_script_path}')

def get_interval_data(params="OB none 00:00:00 23:59:59 2013.01.15"):
    # check if params are valid
    
    with open("logs/api_log.txt", "a") as log_file:
        log_file.write(f"params in UTILS: {params}\n")
    result = kx.q(f'getIntervalData buildParams["{params}"]').py()
    # write log to file
    with open("logs/api_log.txt", "a") as log_file:
        log_file.write(f"result in UTILS: {result}\n")
    return result

def get_qualifiers_amount(params="OB none 00:00:00 23:59:59 2013.01.15"):
    # get qualifiers amount
    with open("logs/api_log.txt", "a") as log_file:
        log_file.write(f"params in QUALIFIERS: {params}\n")

    result = kx.q(f'getDistributionQualifier buildParams["{params}"]').py()

    
    # write log to file
    with open("logs/api_log.txt", "a") as log_file:
        log_file.write(f"result in QA__UTILS: {result}\n")
    return result


# def main():
#     start_up()
#     res = get_qualifiers_amount()
#     print("DA")
#     print(res)
#     return res

# if __name__ == "__main__":
#     main()