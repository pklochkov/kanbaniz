/**
 * Created by pavel on 16.04.2017.
 */
({
     showMenu: function(cmp,isOpen){
        var item = cmp.find('dropdown')
        if(isOpen){
            $A.util.addClass(item,'slds-is-open');
        } else {
            $A.util.removeClass(item,'slds-is-open');
        }
        cmp.set('v.isOpen', isOpen);
    }
})