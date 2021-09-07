<?php
/**
 * @file
 * The primary PHP file for this theme.
 */

function pneumaco_menu_tree__main_menu($variables)
{
    return '<ul class="nav nav-stacked nav-pills" id="mainmenu">' . $variables['tree'] . '</ul>';

}

function pneumaco_form_alter(&$form,&$form_state, $form_id) {
    if($form_id == 'user_login_block') {
        $form['#attributes']['class'][] = 'collapse';
        $form['header'] = array(
            '#markup' => t('<p class="well">You were instructed not to click that...</p>') ,
            '#weight' => -10
        );
    }
}

/* Template overrides */
    $variables['content_column_class'] = ' class="col-sm-10"';