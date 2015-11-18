/**
 * Created by lawebshop on 15-08-18.
 */

var ready = function() {

    $("#sidebar-sales li").first().find("a").click(function () {

        $("#spree_sales_file").click();
        return false;
    });

    $("#spree_sales_file").change(function () {
        $(this).parents("form").submit();
    });
};


$(document).ready(ready);
$(document).on('page:load', ready);