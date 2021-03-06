% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_index.R
\name{build_index}
\alias{build_index}
\title{Build index for mapping using Salmon}
\usage{
build_index(species = c("human", "mouse", "rat"), kmer = 31, destdir,
  ens_release = 92)
}
\arguments{
\item{species}{name of the species. Only \code{'human'}, \code{'mouse'}, and \code{'rat'} are allowed to use.}

\item{kmer}{k-mer size for indexing. default is 31. See \code{'Salmon'} for details.}

\item{destdir}{directory to save index files.}

\item{ens_release}{version of Ensembl release.}
}
\value{
directory of index files
}
\description{
\code{build_index} for mapping reads using Salmon.
}
\examples{
build_index(species="rat", kmer=31, destdir="/mnt/raid/test", ens_release=92)

}
\references{
Rob Patro, Geet Duggal, Michael I. Love, Rafael A. Irizarry, and Carl Kingsford (2017):
Salmon provides fast and bias-aware quantification of transcript expression. Nature methods, 14(4), 417.
\url{https://www.nature.com/articles/nmeth.4197}
}
