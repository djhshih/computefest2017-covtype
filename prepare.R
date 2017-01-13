library(io);

x <- read.table("covtype.data", sep=",", header=FALSE);
attrs <- qread("attributes.tsv");
cover <- qread("forest-cover-types.tsv");
wilderness <- qread("wilderness_area.tsv");
soil <- qread("soil-types.tsv");
soil.d1 <- qread("soil-type_usfs-elu-code_d1.tsv");
soil.d2 <- qread("soil-type_usfs-elu-code_d2.tsv");

attr.names <- unlist(mapply(function(x, n) rep(x, n), as.character(attrs$name), attrs$n_columns));
names(attr.names) <- NULL;

stopifnot(length(attr.names) == ncol(x));
colnames(x) <- attr.names;

x$Cover_Type <- factor(x$Cover_Type, levels=cover$code, labels=cover$label);

soil.df <- x[, colnames(x) == "Soil_Type"];
soil.vtr <- character(nrow(soil.df));
for (i in 1:nrow(soil)) {
	soil.vtr[soil.df[, i] == 1] <- soil$usfs_elu_code[i];
}

wilderness$label <- as.character(wilderness$label);
wilderness.df <- x[, colnames(x) == "Wilderness_Area"];
wilderness.vtr <- character(nrow(wilderness.df));
for (i in 1:nrow(wilderness)) {
	wilderness.vtr[wilderness.df[, i] == 1] <- wilderness$label[i];
}

d <- data.frame(
	x[, ! colnames(x) %in% c("Soil_Type", "Wilderness_Area")],
	Soil_Type = soil.vtr,
	Wilderness_Area = wilderness.vtr
);

colnames(x)[colnames(x) == "Soil_Type"] <- paste0("Soil_Type_", soil$usfs_elu_code);
colnames(x)[colnames(x) == "Wilderness_Area"] <- paste0("Wilderness_Area_", gsub(" ", "_", wilderness$label, fixed=TRUE));

qwrite(x, "data_expanded.rds");
qwrite(d, "data.rds");

