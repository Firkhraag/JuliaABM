import torch
import numpy as np
import sbi.utils as utils
from sbi.inference.base import infer
import pandas as pd
import os
from matplotlib import pyplot as plt
import seaborn as sns
import csv

from sbi.inference import SNPE

# determine the supported device
def get_device():
    if torch.cuda.is_available():
        device = torch.device('cuda:0')
    else:
        device = torch.device('cpu') # don't have GPU 
    return device

# convert a df to tensor to be used in pytorch
def df_to_tensor(df):
    device = get_device()
    return torch.from_numpy(df.values).float().to(device)

# n_samples = 1000
# dirname = os.path.dirname(__file__)
# filename = os.path.join(dirname, '../output/tables/data_y.csv')

# y_data = pd.read_csv(filename).iloc[:, 0].to_list()
# print(type(y_data))
# print(type([12, 2, 3]))
# exit()

prior = utils.BoxUniform(
    #                d,     s                                 t                                         r                           p
    low=torch.tensor([0.1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 30, 30, 30, 30, 30, 30, 30, 0.0008, 0.0005, 0.0002, 0.000005]),
    high=torch.tensor([1.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, -0.01, -0.01, -0.01, -0.01, -0.01, -0.01, -0.01, 365, 365, 365, 365, 365, 365, 365, 0.0012, 0.001, 0.0005, 0.00001])
)

#SNPE or SNLE or SNRE
inference = SNPE(prior=prior)

num_initial_runs = 1000

dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, '../output/tables/lhs_params.csv')
X = df_to_tensor(pd.read_csv(filename, index_col=False, header=None))

dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, '../output/tables/lhs_y.csv')
y = df_to_tensor(pd.read_csv(filename, index_col=False, header=None))

# print(X.shape)
# print(y.shape)
# exit()

_ = inference.append_simulations(X, y).train()
posterior = inference.build_posterior()

n_samples = 1000
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, '../output/tables/data_y.csv')

y_data = pd.read_csv(filename, index_col=False, header=None).iloc[:, 0].to_list()
params_res = posterior.sample((n_samples,), x=y_data)

sns.displot(data=pd.DataFrame(params_res[:, 0].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/delta_distribution.pdf")
plt.xlabel("δ")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()

sns.displot(data=pd.DataFrame(params_res[:, 1].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/beta_FluA_distribution.pdf")
plt.xlabel("β1")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 2].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/beta_FluB_distribution.pdf")
plt.xlabel("β2")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 3].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/beta_RV_distribution.pdf")
plt.xlabel("β3")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 4].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/beta_RSV_distribution.pdf")
plt.xlabel("β4")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 5].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/beta_AdV_distribution.pdf")
plt.xlabel("β5")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 6].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/beta_PIV_distribution.pdf")
plt.xlabel("β6")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 7].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/beta_CoV_distribution.pdf")
plt.xlabel("β7")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()

sns.displot(data=pd.DataFrame(params_res[:, 8].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/gamma_FluA_distribution.pdf")
plt.xlabel("γ1")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 9].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/gamma_FluB_distribution.pdf")
plt.xlabel("γ2")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 10].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/gamma_RV_distribution.pdf")
plt.xlabel("γ3")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 11].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/gamma_RSV_distribution.pdf")
plt.xlabel("γ4")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 12].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/gamma_AdV_distribution.pdf")
plt.xlabel("γ5")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 13].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/gamma_PIV_distribution.pdf")
plt.xlabel("γ6")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 14].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/gamma_CoV_distribution.pdf")
plt.xlabel("γ7")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()

sns.displot(data=pd.DataFrame(params_res[:, 15].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/r_FluA_distribution.pdf")
plt.xlabel("r1")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 16].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/r_FluB_distribution.pdf")
plt.xlabel("r2")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 17].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/r_RV_distribution.pdf")
plt.xlabel("r3")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 18].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/r_RSV_distribution.pdf")
plt.xlabel("r4")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 19].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/r_AdV_distribution.pdf")
plt.xlabel("r5")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 20].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/r_PIV_distribution.pdf")
plt.xlabel("r6")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 21].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/r_CoV_distribution.pdf")
plt.xlabel("r7")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()

sns.displot(data=pd.DataFrame(params_res[:, 22].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/p_2_distribution.pdf")
plt.xlabel("p1")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 23].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/p_6_FluB_distribution.pdf")
plt.xlabel("p2")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 24].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/p_14_RV_distribution.pdf")
plt.xlabel("p3")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()
sns.displot(data=pd.DataFrame(params_res[:, 25].numpy()), kde=True, legend = False)
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "../output/plots/sbi/p_15_RSV_distribution.pdf")
plt.xlabel("p4")
plt.savefig(filename, format="pdf", bbox_inches="tight")
plt.clf()

# duration_parameter = 0.5970591902732849
# susceptibility_parameters = [4.0567, 4.1362, 2.3267, 4.1394, 3.8720, 2.8843, 4.1205)]
# temperature_parameters = [-0.7179, -0.6494, -0.2721, -0.1998, -0.3627, -0.4182, -0.5508)]
# mean_immunity_durations = [170.2339, 169.7207, 177.3863, 249.1770, 228.9637, 193.8505, 284.3898)]
# random_infection_probabilities = [0.0010, 0.0008, 0.0003, 7.9549e-06)]

print(f'duration_parameter = {torch.mean(params_res[:, 0])}')
print(f'susceptibility_parameters = {[torch.mean(params_res[:, 1]), torch.mean(params_res[:, 2]), torch.mean(params_res[:, 3]), torch.mean(params_res[:, 4]), torch.mean(params_res[:, 5]), torch.mean(params_res[:, 6]), torch.mean(params_res[:, 7])]}')
print(f'temperature_parameters = {[torch.mean(params_res[:, 8]), torch.mean(params_res[:, 9]), torch.mean(params_res[:, 10]), torch.mean(params_res[:, 11]), torch.mean(params_res[:, 12]), torch.mean(params_res[:, 13]), torch.mean(params_res[:, 14])]}')
print(f'mean_immunity_durations = {[torch.mean(params_res[:, 15]), torch.mean(params_res[:, 16]), torch.mean(params_res[:, 17]), torch.mean(params_res[:, 18]), torch.mean(params_res[:, 19]), torch.mean(params_res[:, 20]), torch.mean(params_res[:, 21])]}')
print(f'random_infection_probabilities = {[torch.mean(params_res[:, 22]), torch.mean(params_res[:, 23]), torch.mean(params_res[:, 24]), torch.mean(params_res[:, 25])]}')
