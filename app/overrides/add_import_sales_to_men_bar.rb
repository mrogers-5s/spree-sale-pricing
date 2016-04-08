Deface::Override.new(:virtual_path=>'spree/admin/shared/_main_menu',
                     :name => 'add_import_sale_to_men_bar',
                     :insert_after =>"erb[silent]:contains('current_store')~erb[silent]",
                     :text         =>"<ul class='nav nav-sidebar'>
                                       <% if can? :admin, Spree::SalePrice %>
                                        <%= main_menu_tree 'Soldes', icon: 'gift', sub_menu: 'spree_sales', url: '#sidebar-sales' %>
                                      <% end %>
                                     </ul>")