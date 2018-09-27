//
//  SmartRxLocalitySearchVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 09/08/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxLocalitySearchVC.h"

@interface SmartRxLocalitySearchVC ()
{
    BOOL isSeraching;
}
@property(nonatomic,strong) NSArray *searchedArray;
@end

@implementation SmartRxLocalitySearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)clickOnClseBtn:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if (isSeraching) {
        count = self.searchedArray.count;
    }else{
        count = self.localtyArray.count;
    }
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    LocaltyResponseModel *model ;
    if (isSeraching) {
        model = self.searchedArray[indexPath.row];
    }else{
        model = self.localtyArray[indexPath.row];
    }
        cell.textLabel.text = model.localityName;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LocaltyResponseModel *model ;
    if (isSeraching) {
        model = self.searchedArray[indexPath.row];
    }else{
        model = self.localtyArray[indexPath.row];
    }    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate selecedLocalty:model];
    }];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length < 1 ) {
        isSeraching = NO;
    } else {
        isSeraching = YES;
        
    }
    [self filterUsingSearchText:searchText];

}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text.length < 1 ) {
        isSeraching = NO;
    } else {
        isSeraching = YES;
        
    }
    [self filterUsingSearchText:searchBar.text];
    [searchBar resignFirstResponder];
}
-(void)filterUsingSearchText:(NSString *)searchText{
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@",
     @"localityName", searchText];
    
    self.searchedArray = [self.localtyArray filteredArrayUsingPredicate:predicate];
    if (self.searchedArray.count || isSeraching == NO) {
        self.tableView.hidden = NO;
    } else {
        self.tableView.hidden = YES;
    }
    [self.tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
