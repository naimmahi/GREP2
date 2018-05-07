#' Wrapper function to run tximport
#'
#' \code{run_tximport} function runs tximport on transcript level abundances from Salmon to summarize to gene level. See Bioconductor package
#' \code{'tximport'} for details.
#'
#' We use Ensembl annotation for both genes and transcripts. 
#' 
#' @param srr_id SRA run accession ID.
#' @param species name of the species. Only \code{'human'}, \code{'mouse'}, and \code{'rat'} are allowed to use.
#' @param salmon_dir directory where salmon files are saved.
#' @param countsFromAbundance whether to generate counts based on abundance. Available options are: \code{'no'}, 
#' \code{'scaledTPM'} (abundance based estimated counts scaled up to library size), 
#' \code{'lengthScaledTPM'} (default, scaled using the average transcript length over samples and library size). See Bioconductor package \code{'tximport'} for further details.
#'
#' @return a list of gene and transcript level estimated counts summarized by Bioconductor package \code{'tximport'}.
#' 
#' @references 
#' 
#' Charlotte Soneson, Michael I. Love, Mark D. Robinson (2015):
#' Differential analyses for RNA-seq: transcript-level estimates
#' improve gene-level inferences. F1000Research.
#' \url{http://dx.doi.org/10.12688/f1000research.7563.1}
#' 
#' @examples
#'
#' run_tximport(srr_id="SRR6324192", species="human", salmon_dir="/home/salmon", countsFromAbundance = "lengthScaledTPM")
#'
#' @export 
run_tximport <- function(srr_id, species=c("human","mouse","rat"), salmon_dir, countsFromAbundance = c("no","scaledTPM","lengthScaledTPM")){
	
	countsFromAbundance <- match.arg(countsFromAbundance, c("no","scaledTPM","lengthScaledTPM"))
	species <- match.arg(species, c("human","mouse","rat"))
	edb= function(species) {
		if (species == "human") {
			transcripts(EnsDb.Hsapiens.v86, columns = c("tx_id","gene_id", "gene_name"), return.type = "DataFrame")
		} else if (species == "mouse") {
			transcripts(EnsDb.Mmusculus.v79, columns = c("tx_id","gene_id", "gene_name"), return.type = "DataFrame")
		} else if (species == "rat") {
			transcripts(EnsDb.Rnorvegicus.v79, columns = c("tx_id","gene_id", "gene_name"), return.type = "DataFrame")
		} else {
			return(NULL)
		}
	}
	gene_ensembl= function(species) {
		if (species == "human") {
			return(org.Hs.eg.db)
		} else if (species == "mouse") {
			return(org.Mm.eg.db)
		} else if (species == "rat") {
			return(org.Rn.eg.db)
		} else {
			return(NULL)
		}
	}

	assign('Tx.ensemble', edb(species))
	Tx.ensemble <- get('Tx.ensemble')	
	tx2gene<- Tx.ensemble[,c(1,2)]
	files <- file.path(paste0(salmon_dir,"/",srr_id,"_transcripts_quant/",srr_id, "_quant_new.sf"))

	cat("generating counts table\n")
	
	tx.t <- tximport(files, type = "salmon", tx2gene = tx2gene, txOut=TRUE, importer = read.delim, countsFromAbundance = countsFromAbundance)
	if(all(apply(is.na(tx.t$counts), 2, any))==TRUE ) {
		txi.t <- tximport(files, type = "salmon", tx2gene = tx2gene, txOut=TRUE, importer = read.delim, dropInfReps=TRUE, countsFromAbundance = "no")
	} else {
		txi.t <- tx.t
	}
	txi.g <- tximport::summarizeToGene(txi.t, tx2gene)
	
	gene_counts <- txi.g$counts
	gene_counts[is.na(gene_counts)]<-0	
	colnames(gene_counts) <- srr_id
	transcript_counts <- txi.t$counts
	transcript_counts[is.na(transcript_counts)]<-0	
	colnames(transcript_counts) <- srr_id
	
	annot_genes <- AnnotationDbi::select(gene_ensembl(species),keys=rownames(gene_counts),columns=c("SYMBOL","SYMBOL", "GENENAME"),keytype="ENSEMBL")	
	annot_genes2 <- annot_genes[match(rownames(gene_counts), annot_genes[,1]),,drop=F]
	gene_counts <- cbind(annot_genes2,gene_counts)
	
	counts <- list(gene_counts=gene_counts, transcript_counts=transcript_counts, tximport_gene_data=txi.g, tximport_transcript_data=txi.t)
	return(counts)
}