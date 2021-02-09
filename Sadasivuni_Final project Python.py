import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings("ignore")

df = pd.read_csv('/Users/chai/Desktop/AIT580/Assignments/Final project/Inpatient_Prospective_Payment_System__IPPS__Provider_Summary_for_the_Top_100_Diagnosis-Related_Groups__DRG__-_FY2011.csv')

#Grouping by drg
df.columns = [column.strip() for column in df.columns]
agg_columns = ['mean', 'median', 'var', 'std', 'count', 'min', 'max']
groupby_drg = df[['DRG Definition', 'Average Total Payments']].groupby(by='DRG Definition').agg(agg_columns)
groupby_drg.columns = [header + '-' + agg_column for header, agg_column in zip(groupby_drg.columns.get_level_values(0), agg_columns)]
groupby_drg.columns = groupby_drg.columns.get_level_values(0)
groupby_drg.reset_index(inplace=True)
groupby_drg['Average Total Payments-range'] = groupby_drg['Average Total Payments-max'] - groupby_drg['Average Total Payments-min']
groupby_drg.head()

#Defining a function for plotting a bar chart
def plt_setup(_plt):
    _plt.tick_params(axis='x', which='both', bottom='off', top='off', labelbottom='off')
    
#A few treatments (DRG Definitions) are noticeably more costly than others, so displaying the Mean Average Total Payments by DRG
plt.figure(figsize=(20,5))
sns.barplot(x='DRG Definition', y='Average Total Payments-mean', 
            data=groupby_drg.sort_values('Average Total Payments-mean'))
plt_setup(plt)
plt.title('Mean Average Total Payments by DRG', fontsize=16)
plt.ylabel('Mean of Average Total Payments', fontsize=16)
plt.xticks(rotation=90)
plt.savefig("1.pdf",bbox_inches='tight')

#Total Discharges vs. Average Total Payments
plt.scatter(df['Total Discharges'],df['Average Total Payments'])
plt.xlabel('Total Discharges')
plt.ylabel('Average Total Payments')
plt.title('Total Discharges vs. Average Total Payments')
plt.savefig("2.pdf",bbox_inches='tight')

#correlation matrix
df.corr()

#correlation plot
X = df.corr()
a = sns.heatmap(X, annot=True, fmt="d",vmin=-1,vmax=1)
a.set_title("Correlation Matrix")

#correlation plot with numbers
X = df.corr()
b = sns.heatmap(X, annot=True)
b.set_title("Correlation Matrix")
