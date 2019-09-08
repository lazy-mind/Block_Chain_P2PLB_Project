import csv
import time



# data comes from: https://www.kaggle.com/wendykan/lending-club-loan-data

# Column  2  is :  loan_amnt
# Column  3  is :  funded_amnt
# Column  5  is :  term

# Column  6  is :  int_rate
# Column  8  is :  grade

# Column  10  is :  emp_title
# Column  13  is :  annual_inc

# Column  16  is :  loan_status
# Column  20  is :  purpose
# Column  21  is :  title

# since the dataset has no memeber id
# we cannot match the member with specific grade
# therefore, we calculate the mean grade and apply it fo all users

# Related to loans
loan_request = []
lend_issued = []
loan_term = []
loan_purpose = []
loan_title = []

# Related to user credit and interest rate
interest_rate = []
user_grade = []

# Related to user profile
emp_title = []
annula_income = []

time1 = time.time()

with open('loan.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0

    user_dict = {}

    for row in csv_reader:
        if line_count>10000:
            pass
            # break
        if line_count != 0:
            try:
                loan_request.append(float(row[2]))
                lend_issued.append(float(row[3]))
                
                if row[5]==' 36 months':
                    loan_term.append(36)
                elif row[5]==' 60 months':
                    loan_term.append(60)
                else:
                    loan_term.append(0)
                
                loan_purpose.append(row[20])
                loan_title.append(row[21])

                interest_rate.append(float(row[6]))

                if row[8]=='A':
                    user_grade.append(20)
                elif row[8]=='B':
                    user_grade.append(15)
                elif row[8]=='C':
                    user_grade.append(10)
                elif row[8]=='D':
                    user_grade.append(5)
                else:
                    user_grade.append(0)

                emp_title.append(row[10])
                annual_inc.append(row[13])
            except Exception as e:
                pass
            # print(f'Column names are {", ".join(row)}')
            for i in range(1,200):
                try:
                    pass
                    # loa n_request.append(row[])
                    # print("Column ",i," is : ",row[i])
                except:
                    break
            # print('Column: 1.',row[0],"2.",row[1],"3.",row[2],"4.",row[3])
            line_count += 1
        else:
            # print(f'\t{row[0]} works in the {row[1]} department, and was born in {row[2]}.')
            # print((row[1]))
            # print(str(row[1]))
            try:
                user_dict[str(row[1])] += 1
            except:
                user_dict[str(row[1])] = 1
            line_count += 1
    print(f'Processed {line_count} lines.')


    # print(user_grade)

    index = 0
    for i in [loan_request,lend_issued,loan_term,interest_rate,user_grade]:
        names = ['loan_request','lend_issued','loan_term','interest_rate','user_grade']
        average = sum(i)/len(i)
        print(names[index],' info: ')
        print('min: ',min(i))
        print('max: ',max(i))
        print('average: ',average)
        proportion = [a for a in i if a >= average]
        print('Above Average: ',len(proportion)/len(i))
        index += 1

    for key in user_dict:
        print(key," -- ",user_dict[key])

index = 0
for i in [loan_request,lend_issued,loan_term,interest_rate,user_grade]:
    names = ['loan_request.txt','lend_issued.txt','loan_term.txt','interest_rate.txt','user_grade.txt']
    text_file = open(names[index], "w")
    for num in i:
        text_file.write("%s\n" % num)
        pass
    text_file.close()
    index += 1
    
time2 = time.time()

# Processed 2260669 lines.

# loan_request  info: 
# min:  500.0
# max:  40000.0
# average:  15046.931227849467

# lend_issued  info: 
# min:  500.0
# max:  40000.0
# average:  15041.664056818605

# loan_term  info: 
# min:  36
# max:  60
# average:  42.91031854301472

# interest_rate  info: 
# min:  5.31
# max:  30.99
# average:  13.09291294419326

# user_grade  info: 
# min:  1
# max:  5
# average:  3.365366785392636

# member_id  --  1
# function took 41177.990 ms
print('function took {:.3f} ms'.format((time2-time1)*1000.0))










