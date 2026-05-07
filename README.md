#  Calinski-Harabasz Index — Cluster Detection in R

> Course Project — EIDIA · UEMF · École d'Ingénierie Digitale et d'Intelligence Artificielle
> Semester 6 · Unsupervised Learning · Clustering Validation

---

##  Objective

This project evaluates the **Calinski-Harabasz (CH) Index** for detecting the optimal number of clusters (k) on benchmark clustering datasets.

The study compares the detected number of clusters with the real number of clusters using the CH validation metric under different preprocessing conditions.

---

##  Datasets

| Dataset | Real k | Description                             |
| ------- | ------ | --------------------------------------- |
| **A1**  | 20     | Gaussian clusters with partial overlaps |
| **A2**  | 35     | Gaussian clusters with variable sizes   |
| **R15** | 15     | Well-separated spherical clusters       |
| **D31** | 31     | Dense Gaussian overlapping clusters     |

---

##  Calinski-Harabasz Index

The Calinski-Harabasz index is defined as:

[
CH(k) = \frac{B(k)/(k-1)}{W(k)/(n-k)}
]

Where:

* (B(k)): inter-cluster dispersion
* (W(k)): intra-cluster dispersion
* (k): number of clusters
* (n): number of observations

The optimal number of clusters corresponds to the value of (k) that maximizes the CH index.

---

##  Results

| Dataset | Real k | Detected k |
| ------- | ------ | ---------- |
| A1      | 20     | 27         |
| A2      | 35     | 69         |
| R15     | 15     | 18         |
| D31     | 31     | 45         |

### Observations

* **R15** gives the best performance because clusters are well separated.
* **A1**, **A2**, and **D31** show over-segmentation.
* The CH index tends to favor compact subclusters when overlap exists.

---

##  Impact of Normalization

Different preprocessing methods were tested:

* Raw data
* Z-Score normalization
* Min-Max normalization

Normalization did not significantly improve performance on these synthetic datasets and sometimes degraded the clustering quality.

---

##  Strengths

* Simple interpretation
* Fast computation
* Effective on compact spherical clusters
* Widely used clustering validation metric

---

##  Limitations

* Sensitive to overlapping clusters
* Tends to overestimate the number of clusters
* Less effective on non-convex structures
* Performance depends on cluster geometry

---

##  Author

**Aya Driouche**

> UEMF · École d'Ingénierie Digitale et d'Intelligence Artificielle · 2025–2026
