// Jekyll only generates static page content
// all dynamic page updates are done on client via javascript

// show anchors when hovering over headings, using anchor.js
(function () {
    const headings = ".content h2[id], .content h3[id], .content h4[id], .content h5[id], .content h6[id]";
    anchors.options = { placement: "right" };
    anchors.add(headings);
})();

// filter cards on ?category=value
$(document).ready(function() {
    const urlParams = new URLSearchParams(window.location.search);
    
    if (urlParams.has("category") && urlParams.get("category") != "") {
        const category = urlParams.get("category"); // returns 1st category value + decode URI
        const cleanCategory = $.trim(category.toLowerCase()); // as written in .card data-categories
        
        // hide card if it does not contain the selected category
        $(".card").each(function() {
            const cardCategories = $(this).data("categories").split("|");
            if (!cardCategories.includes(cleanCategory)) {
                $(this).parent().addClass("d-none");
            }
        });

        // add category badges to jumbotron
        $(".jumbotron .categories").append(
            '<a class="badge badge-pill" href="' +  page.url  + '">' + category + '</a>'
        );
    }
});
