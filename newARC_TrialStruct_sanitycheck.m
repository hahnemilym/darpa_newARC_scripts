{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\n",
    "\n",
    "df = pd.read_csv('ARC_trials_v3_mri.csv',index_col=False)\n",
    "df=pd.DataFrame(df)\n",
    "\n",
    "trial_1 = df.iloc[0:81]\n",
    "trial_2 = df.iloc[81:162]\n",
    "trial_3 = df.iloc[162::]\n",
    "\n",
    "block1_time_sec = sum(trial_1['ITI']+(5.25*81))\n",
    "block1_time_min = (sum(trial_1['ITI'])+(5.25*81))/60\n",
    "\n",
    "block2_time_sec = sum(trial_2['ITI'])+(5.25*81)\n",
    "block2_time_min = (sum(trial_2['ITI'])+(5.25*81))/60\n",
    "\n",
    "block3_time_sec = sum(trial_3['ITI'])+(5.25*81)\n",
    "block3_time_min = (sum(trial_3['ITI'])+(5.25*81))/60\n",
    "\n",
    "\n",
    "print 'Block 1 | ITI sum: %s' % sum(trial_1['ITI'])\n",
    "print '        | Total Block Time: %s sec (%s minutes)' % (block1_time_sec,block1_time_min)\n",
    "print '        | Risk sum: %s' % sum(trial_1['Risk'])\n",
    "print '        | reward sum: %s \\n' % sum(trial_1['Reward'])\n",
    "\n",
    "print 'Block 2 | ITI sum: %s' % sum(trial_2['ITI'])\n",
    "print '        | Total Block Time: %s sec (%s minutes)' % (block2_time_sec,block2_time_min)\n",
    "print '        | Risk sum: %s' % sum(trial_2['Risk'])\n",
    "print '        | Reward sum: %s \\n' % sum(trial_2['Reward'])\n",
    "\n",
    "print 'Block 3 | ITI sum: %s' % sum(trial_3['ITI'])\n",
    "print '        | Total Block Time: %s sec (%s minutes)' % (block3_time_sec,block3_time_min)\n",
    "print '        | Risk sum: %s' % sum(trial_3['Risk'])\n",
    "print '        | Reward sum: %s' % sum(trial_3['Reward'])\n",
    "\n",
    "\n",
    "# display(trial_1.head())\n",
    "# display(trial_2.head())\n",
    "# display(trial_3.head())\n",
    "\n",
    "# print trial_1['ITI'].value_counts()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {
    "scrolled": false
   },
   "outputs": [],
   "source": [
    "import os\n",
    "import pandas as pd\n",
    "import numpy as np\n",
    "# import tables\n",
    "\n",
    "dir='/Users/emilyhahn/projects/new_arc/DATA/NEW-ARC_CSV_OUT/'\n",
    "\n",
    "sub_list=[]\n",
    "sub_files_list=[]\n",
    "\n",
    "for root, dirs, files in os.walk(dir, topdown=False):\n",
    "    for name in files:\n",
    "        sub_list.append(name[:5])\n",
    "        sub_files_list.append(name)\n",
    "\n",
    "for sub,csv in zip(sub_list,sub_files_list):\n",
    "    d=os.path.join(dir,csv)\n",
    "    df=pd.read_csv(d)\n",
    "    print df['ConflictType']\n",
    "    "
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 2",
   "language": "python",
   "name": "python2"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 2
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython2",
   "version": "2.7.13"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2
}
