# https://stackoverflow.com/questions/1358003/tricks-to-manage-the-available-memory-in-an-r-session
# improved list of objects
ls.objects <- function (pos = 1, pattern, order.by,
                        decreasing=FALSE, head=FALSE, n=5, ndim=5) {
    napply <- function(names, fn) sapply(names, function(x)
                                         fn(get(x, pos = pos)))
    names <- ls(pos = pos, pattern = pattern)
    obj.class <- napply(names, function(x) as.character(class(x))[1])
    if (length(obj.class) != 0) {
        obj.mode <- napply(names, mode)
        obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
        obj.prettysize <- napply(names, function(x) {
                               format(utils::object.size(x), units = "auto") })
        obj.size <- napply(names, object.size)
        obj.relsize <- round(obj.size/max(obj.size), 3)
        obj.dim <- t(napply(names, function(x) dim(x) ))
        maxdim <- max(sapply(obj.dim, length))
        if (maxdim == 0) { # all vectors or functions
            maxdim <- 1
        }
        tmp <- array(NA, c(length(obj.dim), maxdim))
        for (i in 1:length(obj.dim)) {
            if (is.null(obj.dim[[i]])) {
                tmp[i,] <- NA 
            } else {
                tmp[i,1:length(obj.dim[[i]])] <- obj.dim[[i]]
            }
        }
        obj.dim <- tmp
        vec <- apply(obj.dim, 1, function(x) all(is.na(x))) & (obj.type != "function")
        obj.dim[vec, 1] <- napply(names, length)[vec]
        out <- data.frame(obj.type, obj.size, obj.prettysize, obj.relsize, obj.dim)
        names(out) <- c("Type", "Size [B]", "PrettySize", "RelSize", paste0("dim", 1:maxdim))
        ndim <- min(ndim, maxdim)
        if (!missing(order.by))
            out <- out[order(out[[order.by]], decreasing=decreasing), 1:(4+ndim)]
        if (head)
            out <- head(out[,1:(4+ndim)], n)
        out
    } else {
        message("No objects in search()[pos=", pos, "] = ", search()[pos])
    } # if there are objects
} # ls.objects

# shorthand
ls2 <- function(..., n=10) {
    ls.objects(..., order.by="RelSize", decreasing=TRUE, head=TRUE, n=n)
}

