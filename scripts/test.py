# Import the modules
import sys
import random

def ret_num(num1,num2,num3):
    return num1+num2+num3+0.3123123

def ret_int(num1,num2,num3):
    print 'Test'
    return num1 + num2 + num3

def ret_str(str):
    return str

def ret_concatenated_str(str1,str2,str3):
	return str1 + str2 + str3

def ret_list(num1,num2,num3):
    return [num1,num2,num3]

def ret_nested_list(num1,num2,num3):
    return [[num1,num2,num3],[[num1,num2,num3]]]

def ret_dict(num1,num2,num3):
    return {1:num1,2:num2,3:num3}
